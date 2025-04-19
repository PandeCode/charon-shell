import { astal, Gtk, Elements, useStack, Astal } from "../../../tslib/react";

const ps = require("../../../lua/utils/ps.lua");
const Anchor = Astal.WindowAnchor;

const { mkPopupToggleAnim } = require("../../../lua/utils/astal.lua");
const { inspect, notify } = require("../../../lua/utils/init.lua");

function fexe(cmd: string) {
  return () => astal.exec_async(cmd);
}

function fbexe(cmd: string) {
  return () => astal.exec_async(["bash", "-c", cmd]);
}

function Center() {
  // btnc("Dark Mode", function() {
  // 				astal.exec "theme.sh dark"
  // 				ps.restart(3)
  //    }),
  // 			btnc("Light Mode", function(){
  // 				astal.exec "theme.sh light"
  // 				ps.restart(3)
  //    }),
  // 		},

  return (
    <div
      vertical
      css={{ minWidth: "30em" }}
      spacing={10}
      className="bg-base00-90  m-4 p-4 rounded-lg border-base03-90 border-solid border-2"
    >
      <scrollable
        hscrollbar_policy={Gtk.PolicyType.NEVER}
        vscrollbar_policy={Gtk.PolicyType.AUTOMATIC}
        className="border-none"
      >
        {/* {Gtk.FontChooserWidget()} */}
        <div vertical spacing={9} className="p-2">
          <div vexpand />
          <button width={200} halign={"CENTER"} onClick={fexe("bg.sh rand")}>
            Rand Bg
          </button>
          <button onClick={fexe("bg.sh rand")}>Rand Bg</button>
          <button onClick={fexe("bg.sh rand")}>Rand Bg</button>
          <button onClick={fexe("bg.sh rand")}>Rand Bg</button>
          <button onClick={fexe("bg.sh rand")}>Rand Bg</button>
          <button onClick={fexe("bg.sh rand")}>Rand Bg</button>
          <button onClick={fexe("bg.sh rand")}>Rand Bg</button>
          <button onClick={fexe("bg.sh rand")}>Rand Bg</button>
          <button onClick={fexe("bg.sh rand")}>Rand Bg</button>
          <button onClick={fexe("bg.sh rand")}>Rand Bg</button>
          <button onClick={fexe("bg.sh rand")}>Rand Bg</button>
          {/* <button onClick={fexe("bg.sh rand")}>Rand Bg</button> */}
          <button onClick={fexe("bg.sh rand")}>Rand Bg</button>
          <button onClick={fexe("bg.sh rand")}>Rand Bg</button>
          <button onClick={fexe("bg.sh rand")}>Rand Bg</button>
          <button onClick={fexe("bg.sh rand")}>Rand Bg</button>
          <button onClick={fexe("bg.sh rand")}>Rand Bg</button>
          <button onClick={fexe("bg.sh rand")}>Rand Bg</button>
          <button onClick={fexe("bg.sh rand")}>Rand Bg</button>
          <button onClick={fexe("bg.sh rand")}>Rand Bg</button>
          <button onClick={fexe("bg.sh rand")}>Rand Bg</button>
          <button onClick={fexe("bg.sh rand")}>Rand Bg</button>
          <button onClick={fexe("bg.sh rand")}>Rand Bg</button>
          <button onClick={fexe("bg.sh rand")}>Rand Bg</button>
          <button onClick={fexe("bg.sh rand")}>Rand Bg</button>
          <button onClick={fexe("bg.sh rand")}>Rand Bg</button>
          <button onClick={fexe("bg.sh rand")}>Rand Bg</button>
          <button onClick={fexe("bg.sh rand")}>Rand Bg</button>
          <button onClick={fexe("bg.sh rand")}>Rand Bg</button>
          <button onClick={fexe("bg.sh rand")}>Rand Bg</button>
          <button onClick={fexe("bg.sh rand")}>Rand Bg</button>
          <button onClick={fexe("bg.sh last")}>Last Bg</button>
          <button onClick={fexe("bg.sh next")}>Next Bg</button>
          <button onClick={fexe("bg.sh prev")}>Prev Bg</button>
          <button onClick={fexe("bg.sh reset")}>Reset Bg</button>
        </div>
        <hr />
        <button
          onClick={() => astal.exec_async("theme.sh dark", () => ps.restart())}
        >
          Dark Mode
        </button>
        <button
          onClick={() => astal.exec_async("theme.sh light", () => ps.restart())}
        >
          Light Mode
        </button>
      </scrollable>
    </div>
  );
}

export default mkPopupToggleAnim(
  Center,
  {
    title: "Center",
    anchor: Anchor.TOP + Anchor.RIGHT + Anchor.BOTTOM,
    class_name: "transparent",
  },
  {
    transition_type: Gtk.RevealerTransitionType.SLIDE_RIGHT,
  },
);
