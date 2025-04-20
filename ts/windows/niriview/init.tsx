import { astal, Astal, Elements } from "../../../tslib/react";
const { inspect, notify } = require("lua.utils.init");
const { exec_async, bind } = astal;

function Network() {
  return (
    <div
      vertical
      css={{ minWidth: "1080px", minHeight: "720px" }}
      spacing={10}
      className="bg-base00-90 m-4 p-4 rounded-lg border-base03-90 border-solid border-2"
    >
      hi
    </div>
  );
}

const { mkPopupToggleAnim } = require("lua.utils.astal");
export default mkPopupToggleAnim(Network, {
  title: "Stats",
  keymode: "ON_DEMAND",
});
