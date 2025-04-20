import {
  astal,
  Astal,
  Gtk,
  Elements,
  Variable,
  toCSS,
} from "../../../tslib/react";
// @ts-ignore
const { ninspect } = require("lua.utils");
function color(prefix: string) {
  return (txt: string) => {
    const [c, t] = txt.split(" ");
    return (
      <p css={{ color: c.slice(0, 7) }}>{prefix + t.padStart(3, " ") + "%"}</p>
    );
  };
}

export default function () {
  const cpu = Variable("#000000 0");
  const mem = Variable("#000000 0");
  const swap = Variable("#000000 0");

  astal.interval(3000, () => {
    astal.exec_async("usage.sh", (o: string) => cpu.set(cpu, o));
    astal.exec_async("mem.sh", (o: string) => mem.set(mem, o));
    astal.exec_async("swap.sh", (o: string) => swap.set(swap, o));
  });

  const refCpu = Variable(null);
  const refMem = Variable(null);
  const refSwap = Variable(null);

  const r1Ref = Variable(null);
  const r2Ref = Variable(null);

  [
    [refCpu, cpu],
    [refMem, mem],
    [refSwap, swap],
  ].forEach(([ref, state]) => {
    state.subscribe(state, (val: string) => {
      const el = ref.get(ref);
      if (el) {
        const out = val.split(" ");
        el.value = (tonumber(out[1]) || 0) / 100;
        el.parent.css = "color: " + out[0].slice(0, 7) + ";";
        el.parent.tooltip_markup = `<span foreground="${out[0]}" size="large">${out[1]} %</span>`;
      }
    });
  });

  return (
    <eventbox
      className="px-2 "
      on_destroy={() => {
        cpu.drop(cpu);
        mem.drop(mem);
        swap.drop(swap);
      }}
      on_button_press_event={() => {
        const r1 = r1Ref.get(r1Ref);
        const r2 = r1Ref.get(r2Ref);
        if (r1 && r2) {
          r1.reveal_child = !r1.reveal_child;
          r2.reveal_child = !r2.reveal_child;
        }
      }}
    >
      <>
        <revealer
          reveal_child
          transition_type={Gtk.RevealerTransitionType.SLIDE_RIGHT}
          transition_duration={500}
          ref={r1Ref}
        >
          <div spacing={10} className="my-1 mx-1 px-1 rounded-full bg-base01">
            {[
              ["\uF4BC", refCpu],
              ["\uEFC5", refMem],
              ["\uebcb", refSwap],
            ].map(([icon, ref]) => {
              return (
                <overlay>
                  <Astal.CircularProgress
                    visible
                    rounded
                    start-at={0}
                    end-at={1}
                    value={0}
                    css={toCSS({ fontSize: "3px" })}
                    ref={ref}
                    width={34}
                  />
                  <p className={"text-2xl"}>{icon}</p>
                </overlay>
              );
            })}
          </div>
        </revealer>
        <revealer
          reveal_child={false}
          transition_type={Gtk.RevealerTransitionType.SLIDE_RIGHT}
          transition_duration={500}
          ref={r2Ref}
        >
          {[
            [cpu, "\uF4BC"],
            [mem, "\uEFC5"],
            [swap, "\uebcb"],
          ].map(([v, icon]) => (
            <div spacing={10} className="my-1 mx-1 px-1 rounded-full bg-base01">
              {v(color(icon))}
            </div>
          ))}
        </revealer>
      </>
    </eventbox>
  );
}
