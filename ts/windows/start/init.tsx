import {
  astal,
  Widget,
  Gtk,
  Variable,
  Astal,
  Elements,
  useStack,
  GdkPixbuf,
} from "../../../tslib/react";

const { truncate, inspect, notify } = require("lua.utils.init");
const { bind } = astal;

const Apps = astal.require("AstalApps");

const { mkPopupToggleAnim, update_icon_pixbuf } = require("lua.utils.astal");

// for _, app in ipairs(apps:fuzzy_query("lutris")) do
//     print(app.name)
// end

function Start() {
  const apps = Apps.Apps({
    name_multiplier: 2,
    entry_multiplier: 0,
    executable_multiplier: 2,
  });

  const text = Variable("");
  const btext = bind(text);

  const ref = Variable(null);

  text.subscribe(text, (t: string) => {
    const flowbox = ref.get(ref);

    if (flowbox != null) {
      for (let child of flowbox.get_children(flowbox)) {
        flowbox.remove(flowbox, child);
        child.destroy(child);
      }

      (apps.fuzzy_query(apps, t) as any[]).forEach((a: any) => {
        flowbox.add(
          flowbox,
          <eventbox
            onClick={() => {
              a.launch(a);
            }}
          >
            <div
              vertical
              width={30}
              height={30}
              className={"bg-base01 shadow rounded-lg p-2 m-2"}
            >
              <Gtk.Image
                ref={(r: any) => {
                  update_icon_pixbuf(
                    r,
                    a["icon-name"] ?? "dialog-error-symbolic",
                    50,
                    50,
                  );
                  return r;
                }}
              />
              <p wrap justify="CENTER">
                {truncate(a.name, 20)}
              </p>
            </div>
          </eventbox>,
        );
      });
    }
  });

  return (
    <div
      vertical
      css={{ minWidth: "480px", minHeight: "720px" }}
      spacing={10}
      className="bg-base00-90 m-4 p-4 rounded-lg border-base03-90 border-solid border-2"
    >
      <Widget.Entry
        hexpand
        placeholder_text={"Search for an app"}
        text={btext.as(btext, (t: string) => tostring(t))}
        on_changed={(self: { text: string }) => text.set(text, self.text)}
      />
      <scrollable expand hscroll="NEVER">
        <div vertical>
          <Gtk.FlowBox
            max_children_per_line={3}
            selection_mode={"NONE"}
            ref={ref}
          />
        </div>
        <div expand />
      </scrollable>
      <hr />
      <div vertical spacing={10}>
        {["~/Downloads", "~/Documents", "~/dev"].map((path) => (
          <button
            onClick={() => astal.exec_async("bash -c 'nautilus " + path + "'")}
          >
            {path}
          </button>
        ))}
      </div>
      <hr />
      <div vertical spacing={4}>
        <p className="text-base05 font-bold">Manuals</p>
        {["~/.config/stylix/palette.html"].map((path) => (
          <button
            onClick={() => astal.exec_async(`bash -c 'xdg-open ${path}'`)}
          >
            {path.split("/").pop()}
          </button>
        ))}
      </div>
      <hr />
      <button onClick={() => astal.exec_async("poweroff")}>Power Off</button>
      <button onClick={() => astal.exec_async("reboot")}>Reboot</button>
    </div>
  );
}

const { TOP, LEFT } = Astal.WindowAnchor;
export default mkPopupToggleAnim(Start, {
  title: "Stats",
  keymode: "ON_DEMAND",
  anchor: TOP + LEFT,
});
