import { Elements, useStack } from "../../../tslib/react";

import Sysinfo from "./sysinfo.tsx";
import Weather from "./weather.tsx";

const { mkPopupToggleAnim } = require("../../../lua/utils/astal.lua");
const { inspect, notify } = require("../../../lua/utils/init.lua");
const Console = require("../../../lua/windows/console.lua");

function Stats() {
  const [stack, switcher] = useStack(
    [<>{Weather()}</>, "Weather"],
    [<>{Sysinfo()}</>, "Sysinfo"],
    [<>{Console()}</>, "Console"],
  );

  return (
    <div
      vertical
      css={{ minWidth: "1080px", minHeight: "720px" }}
      spacing={10}
      className="bg-base00-90 m-4 p-4 rounded-lg border-base03-90 border-solid border-2"
    >
      {switcher}
      {stack}
    </div>
  );
}

export default mkPopupToggleAnim(Stats, {
  title: "Stats",
  keymode: "ON_DEMAND",
});
