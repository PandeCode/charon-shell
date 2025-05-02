import { astal, Gtk, Astal, Elements, bindAs } from "../../../tslib/react";

const { inspect, notify } = require("lua.utils.init");

const { exec_async, bind } = astal;

const Battery = astal.require("AstalBattery");
const PowerProfiles = astal.require("AstalPowerProfiles");

const { update_icon_pixbuf, mkPopupToggleAnim } = require("lua.utils.astal");

function parseDegradation(v: string) {
  switch (v) {
    case "lap detected":
      return <p className="text-base0A">Sitting on the your lap</p>;
    case "high operating temperature":
      return <p className="text-base0F">Close to overheating</p>;
    case "":
      return "Performance is not degraded";
    default:
      return <p className="text-base0F">{v}</p>;
  }
}

function Network() {
  const bat = Battery.get_default();
  const powerprofiles = PowerProfiles.get_default();

  const active = bind(powerprofiles, "active-profile");
  const icon = bind(powerprofiles, "icon-name");

  const profiles = [
    ["power-saver", "battery saving profile"],
    ["balanced", "the default profile"],
    ["performance", "does not care about noise or battery consumption"],
  ];

  return (
    <div
      vertical
      css={{ minWidth: "360px", minHeight: "160px" }}
      spacing={10}
      className="bg-base00-90 m-4 p-4 rounded-lg border-base03-90 border-solid border-2"
    >
      {bindAs(bat, "percentage", (p: number) => (
        <>
          <p halign="START" className="font-bold text-xl">
            Percentage:
          </p>
          <p hexpand halign="END">{`${(p * 100).toFixed(1)}%`}</p>
        </>
      ))}

      {bindAs(bat, "state", (state: string) => (
        <>
          <p halign="START" className="font-bold text-xl">
            State:
          </p>
          <p hexpand halign="END">
            {state}
          </p>
        </>
      ))}

      {bindAs(bat, "time_to_empty", (secs: number) => {
        const value =
          secs > 0
            ? `${Math.floor(secs / 3600)}h ${Math.floor((secs % 3600) / 60)}m`
            : "N/A";
        return (
          <>
            <p halign="START" className="font-bold text-xl">
              Time to Empty:
            </p>
            <p hexpand halign="END">
              {value}
            </p>
          </>
        );
      })}

      {bindAs(bat, "time_to_full", (secs: number) => {
        const value =
          secs > 0
            ? `${Math.floor(secs / 3600)}h ${Math.floor((secs % 3600) / 60)}m`
            : "N/A";
        return (
          <>
            <p halign="START" className="font-bold text-xl">
              Time to Full:
            </p>
            <p hexpand halign="END">
              {value}
            </p>
          </>
        );
      })}

      {bindAs(bat, "energy", (energy: number) => (
        <>
          <p halign="START" className="font-bold text-xl">
            Energy Now:
          </p>
          <p hexpand halign="END">
            {`${energy.toFixed(2)}Wh`}
          </p>
        </>
      ))}

      {bindAs(bat, "energy_full", (energyFull: number) => (
        <>
          <p halign="START" className="font-bold text-xl">
            Energy Full:
          </p>
          <p hexpand halign="END">
            {`${energyFull.toFixed(2)}Wh`}
          </p>
        </>
      ))}

      <hr />
      <div spacing={10}>
        {icon.as(icon, (i: string) => (
          <Gtk.Image
            ref={(r: any) => {
              update_icon_pixbuf(r, i ?? "dialog-error-symbolic", 50, 50);
              return r;
            }}
          />
        ))}
        <>
          <p className="font-bold text-xl">{active}</p>:{" "}
          {parseDegradation(powerprofiles["performance-degraded"])}
        </>
      </div>

      {profiles.map(([p, d]) => (
        <div vertical expand className="rounded-lg bg-base01 shadow-xl p-2 m-2">
          <>
            <p expand className="text-lg font-bold">
              {p}
            </p>
            <button
              halign="END"
              onClick={() => powerprofiles.set_active_profile(powerprofiles, p)}
            >
              Set
            </button>
          </>
          {d}
        </div>
      ))}
    </div>
  );
}

const { TOP, RIGHT } = Astal.WindowAnchor;
export default mkPopupToggleAnim(Network, {
  title: "Stats",
  keymode: "ON_DEMAND",
  anchor: TOP + RIGHT,
});
