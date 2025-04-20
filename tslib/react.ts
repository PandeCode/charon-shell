// @ts-ignore
import _astal = require("astal");

const stat = require("posix").stat;
// const Widget = astal.require.Widget;

const astal = _astal;
export { astal };

const CACHE_DIR = "/home/shawn/.cache/charon-shell/fetch/"; // TODO move

// @ts-ignore
const Elements = require("./Elements.lua");
const Gdk = astal.require("Gdk");
const Gtk = astal.require("Gtk");
const GLib = astal.require("GLib");
const Astal = astal.require("Astal");
const Variable = astal.Variable;

const Widget = require("astal.gtk3.widget");

const toCSS = require("../lua/extras/tailwind/init.lua").toCSS;

const setInterval = (c: CallableFunction, t: number) => astal.interval(t, c);
const setTimeout = (c: CallableFunction, t: number) => astal.timeout(t, c);

export {
  Elements,
  Widget,
  Gdk,
  Gtk,
  GLib,
  Astal,
  Variable,
  setInterval,
  setTimeout,
  toCSS,
};

const { exec_async, read_file_async } = astal;

export function sh(cmd: string) {
  return ["bash", "-c", cmd];
}

export function useState<T>(
  defaultValue: T | undefined = undefined,
  getter: (s: T) => T = (s) => s,
): [SVariable<T>, (fn: T | ((prev: T) => T)) => any, Variable<T>] {
  const variable: Variable<T> = Variable<T>(defaultValue);
  let v: SVariable<T> = variable(getter);
  v._v = variable;

  return [
    v,
    (fn: ((prev: T) => T) | T) =>
      variable.set(
        variable,
        typeof fn === "function"
          ? (fn as CallableFunction)(variable.get(variable))
          : fn,
      ),
    variable,
  ];
}

export function useEffect(fn: () => any, vars: (typeof Variable)[]) {
  if (vars == undefined || vars.length == 0) {
    fn();
  } else {
    for (const v of vars) {
      v._v.subscribe(v._v, fn);
    }
  }
}

export function useStack(...pages: [any, string, string?][]): [Widget, Widget] {
  const stack = Gtk.Stack({
    transition_type: "SLIDE_LEFT_RIGHT",
    transition_duration: 500,
    visible: true,
  });
  const switcher = Gtk.StackSwitcher({ stack });
  for (let index = 0; index < pages.length; index++) {
    const page = pages[index];
    stack.add_titled(stack, page[0], page[2] || "page" + index, page[1]);
  }
  return [stack, switcher];
}

export function useStackSolo(...pages: [any, string, string?][]): Widget {
  const stack = Gtk.Stack({
    transition_type: "SLIDE_LEFT_RIGHT",
    transition_duration: 500,
    visible: true,
  });
  for (let index = 0; index < pages.length; index++) {
    const page = pages[index];
    stack.add_titled(stack, page[0], page[2] || "page" + index, page[1]);
  }
  return stack;
}

export function useCmd(
  cmd: string | string[],
  preprocess?: (out: string) => string,
) {
  const [state, setState] = useState<string>("Loading...");
  exec_async(cmd, (out?: string) => {
    if (out) {
      if (preprocess) setState(preprocess(out));
      else setState(out);
    }
  });
  return state;
}

export function useFile(path: string, preprocess?: (out: string) => string) {
  const [state, setState] = useState<string>("Loading...");
  read_file_async(path, (out?: string) => {
    if (out) {
      if (preprocess) setState(preprocess(out));
      else setState(out);
    }
  });
  return state;
}

export function useFetch<T>(
  url: string,
  preprocess: (out: string) => T = (out: string) => out as T,
): SVariable<T> {
  const [variable, setVariable] = useState<T>();
  astal.exec_async("curl -s " + url, (out: string) => {
    setVariable(preprocess(out));
  });
  return variable;
}

function hash(str: string): string {
  return astal.exec(
    string.format(`sh -c "printf '%%s' '%s' | md5sum | cut -d' ' -f1"`, str),
  );
}

export function removeCache(url: string) {
  const path = CACHE_DIR + hash(url);
  return os.remove(path);
}
export function useFetchCache<T>(
  url: string,
  preprocess: (out: string) => T = (out: string) => out as T,
) {
  const path = CACHE_DIR + hash(url);
  if (stat(path) != null) {
    const [variable, setVariable] = useState<T>();
    astal.read_file_async(path, (out: string) => setVariable(preprocess(out)));
    return variable;
  } else {
    const new_preprocess = (out: string) => {
      astal.write_file_async(path, out);
      return preprocess(out);
    };
    return useFetch<T>(url, new_preprocess);
  }
}
