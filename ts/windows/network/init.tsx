import { astal, Astal, Elements, useStack } from "../../../tslib/react";

import Bluetooth from "./bluetooth";
import Internet from "./internet";

const { inspect, notify } = require("lua.utils.init");

const { exec_async, bind } = astal;

function Network() {
  const [stack, switcher] = useStack(
    [<Internet />, "internet", "page1"],
    [<Bluetooth />, "bluetooth", "page2"],
  );

  switcher.halign = "CENTER";
  return (
    <div
      vertical
      css={{ minWidth: "360px", minHeight: "720px" }}
      spacing={10}
      className="bg-base00-90 m-4 p-4 rounded-lg border-base03-90 border-solid border-2"
    >
      {switcher}
      {stack}
      <div spacing={10}>
        <button hexpand onClick={() => exec_async("nm-connection-editor")}>
          Connection Editor
        </button>
        <button hexpand onClick={() => exec_async("blueman-services")}>
          Blueman Services
        </button>
      </div>
    </div>
  );
}

const { mkPopupToggleAnim } = require("lua.utils.astal");
const { TOP, RIGHT } = Astal.WindowAnchor;
export default mkPopupToggleAnim(Network, {
  title: "Stats",
  keymode: "ON_DEMAND",
  anchor: TOP + RIGHT,
});
