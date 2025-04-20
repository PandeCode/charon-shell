import { astal, Gtk, Elements, Astal } from "../../../tslib/react";
const { TOP, RIGHT } = Astal.WindowAnchor;
const { mkPopupToggleAnim } = require("lua.utils.astal");

const { InfoBar, Calendar, Scale, LevelBar, Spinner } = Gtk;

// const assets = require("lua.assets");

function win() {
  return (
    <div
      vertical
      className="bg-base00 m-2 p-2 rounded-lg"
      css={{ minWidth: "30em" }}
    >
      <button onClick={() => astal.exec("swaync-client -t -sw")}>
        Notification Center
      </button>

      <Calendar />

      <InfoBar message_type={Gtk.MessageType.INFO} />
    </div>
  );
}

export default mkPopupToggleAnim(
  win,
  {
    title: "Time",
    anchor: TOP + RIGHT,
    class_name: "transparent",
  },
  {
    transition_type: Gtk.RevealerTransitionType.SLIDE_DOWN,
  },
);
