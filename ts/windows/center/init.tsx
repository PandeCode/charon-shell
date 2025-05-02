//   get-last        - Output the path of the last used wallpaper
//   get-next        - Output the path of the next wallpaper in the index
//   get-prev        - Output the path of the previous wallpaper in the index
//   get-random      - Output the path of a random wallpaper
//   get-reset       - Output the path of the current wallpaper
//   last            - Set the last used wallpaper
//   next            - Set the next wallpaper in the index
//   prev            - Set the previous wallpaper in the index
//   random          - Set a random wallpaper
//   reset           - Reset to the current wallpaper
//   set IMAGE_PATH  - Set a specific image as wallpaper
//   get-set IMAGE_PATH - Output the path of a specific image with transformations
//   help            - Show this help message
//
// Environment Variables:
//   WALLPAPER_DIR      - Directory containing wallpapers (default: ~/Pictures/walls)
//   GO_WALL            - default(unset) - bool - Theme for gowall transformation
//   GO_WALL_INVERT     - default(unset) - bool - Enable inversion (any non-empty value)
//   GO_WALL_PIXELATE   - default(unset) - int - Pixelation scale
//   GO_WALL_EFFECT     - default(unset) - "(anything)"|"draw border"|"draw grid"|"effect grayscale"|"bg" - Special effect to apply

import {
  astal,
  astalify,
  Gdk,
  Variable,
  GdkPixbuf,
  Gtk,
  Elements,
  useStack,
  Astal,
} from "../../../tslib/react";

const assets = require("lua.assets");

const ps = require("lua.utils.ps");
const { TOP, RIGHT, BOTTOM } = Astal.WindowAnchor;

const { mkPopupToggleAnim } = require("lua.utils.astal");
const { lastIndexOf, ninspect, notify } = require("lua.utils");

function fexe(cmd: string) {
  return () => astal.exec_async(cmd);
}

function fbexe(cmd: string) {
  return () => astal.exec_async(["bash", "-c", cmd]);
}

function Center() {
  const Image = astalify(Gtk.Image);
  const SpinButton = astalify(Gtk.SpinButton);

  const prevImgRef = Variable(null);
  const currImgRef = Variable(null);
  const nextImgRef = Variable(null);

  const invertRef = Variable(null);
  const goWallRef = Variable(null);
  const pixelateRef = Variable(null);

  const borderRef = Variable(null);
  const gridRef = Variable(null);
  const flipRef = Variable(null);
  const grayscaleRef = Variable(null);
  const mirrorRef = Variable(null);

  const getEnv = () => {
    let goWall = goWallRef.get(goWallRef);
    let invert = goWallRef.get(invertRef);
    let pixelate = goWallRef.get(pixelateRef);

    let border = borderRef.get(borderRef);
    let grid = gridRef.get(gridRef);
    let flip = flipRef.get(flipRef);
    let grayscale = grayscaleRef.get(grayscaleRef);
    let mirror = mirrorRef.get(mirrorRef);

    if (
      goWall != null &&
      invert != null &&
      pixelate != null &&
      border != null &&
      grid != null &&
      flip != null &&
      mirror != null &&
      grayscale != null
    ) {
      let env = "SILENT=1 ";
      if (goWall.active) env += " GO_WALL=nix ";
      if (invert.active) env += " GO_WALL_INVERT=1 ";
      if (pixelate.value != 0)
        env += " GO_WALL_PIXELATE='" + tostring(pixelate.value) + "' ";

      let effects = [];

      if (border.active) effects.push("draw border");
      if (grid.active) effects.push("draw grid");
      if (flip.active) effects.push("effects flip");
      if (mirror.active) effects.push("effects mirror");
      if (grayscale.active) effects.push("effects grayscale");

      if (effects.length > 0)
        env += " GO_WALL_EFFECT='" + table.concat(effects, "|") + "'";

      return env;
    }
    return "";
  };

  const loadImg = () => {
    let prevImg = prevImgRef.get(prevImgRef);
    let currImg = currImgRef.get(currImgRef);
    let nextImg = nextImgRef.get(nextImgRef);

    if (prevImg != null && currImg != null && nextImg != null) {
      [
        ["prev", prevImg],
        ["last", currImg],
        ["next", nextImg],
      ].forEach(([c, r]) => {
        astal.exec_async(
          `bash -c "${getEnv()} bg.sh get-${c}"`,
          (s: string, _out: any) => {
            let pixbuf = GdkPixbuf.Pixbuf.new_from_file(s);
            if (pixbuf == null)
              pixbuf = GdkPixbuf.Pixbuf.new_from_file(
                assets.default_image_path,
              );
            r.pixbuf = pixbuf.scale_simple(
              pixbuf,
              192 * 1.2,
              108 * 1.2,
              "BILINEAR",
            );
          },
        );
      });
    }
  };

  const bgfn = (fn: string) => () =>
    astal.exec_async(`bash -c '${getEnv()} bg.sh ${fn}'`, loadImg);

  astal.timeout(500, loadImg);

  //   GO_WALL_PIXELATE   - default(unset) - int - Pixelation scale
  //   GO_WALL_EFFECT     - default(unset) - "(anything)"|"draw border"|"draw grid"|"effect grayscale"|"bg" - Special effect to apply

  const usage = Variable({});
  usage.poll(usage, 5000, ps.getResourceUse);

  return (
    <scrollable
      expand
      hscroll="NEVER"
      on_destroy={() => {
        usage.drop(usage);
      }}
    >
      <div
        vertical
        css={{ minWidth: "30em" }}
        spacing={10}
        className="bg-base00-90  m-4 p-4 rounded-lg border-base03-90 border-solid border-2"
      >
        <button onClick={ps.restart}>Restart Shell</button>
        <button onClick={ps.kill}>Kill Shell</button>

        {usage(
          (v: {
            memory_rss_kb: number;
            memory_vmsize_kb: number;
            threads: number;
            cpu_time_seconds: number;
            open_fds: number;
          }) => `
    RAM (RSS): ${((v.memory_rss_kb ?? 0) / 1000).toFixed(2)} MB
    RAM (Virtual): ${((v.memory_vmsize_kb ?? 0) / 1000).toFixed(2)} MB
    Threads: ${v.threads ?? 0}
    CPU Time: ${v.cpu_time_seconds?.toFixed(2) ?? 0} s
    Open FDs: ${v.open_fds ?? 0}
  `,
        )}

        <hr />
        <Image ref={currImgRef} />
        <>
          <p>Pixelate</p>
          <Gtk.SpinButton
            halign="END"
            adjustment={Gtk.Adjustment({
              lower: 0,
              upper: 100,
              step_increment: 0.1,
              page_increment: 1,
              value: 0,
            })}
            digits={1}
            value={0}
            ref={pixelateRef}
          />
        </>

        <Gtk.FlowBox
          max_children_per_line={6}
          selection_mode={"NONE"}
          margin={20}
          ref={(ref: any) => {
            let els = [
              <p>Go Wall</p>,
              <Gtk.Switch ref={goWallRef} halign="END" />,
              <p>Invert</p>,
              <Gtk.Switch ref={invertRef} halign="END" />,
              <p>Border</p>,
              <Gtk.Switch ref={borderRef} halign="END" />,
              <p>Grid</p>,
              <Gtk.Switch ref={gridRef} halign="END" />,
              <p>Flip</p>,
              <Gtk.Switch ref={flipRef} halign="END" />,
              <p>Grayscale</p>,
              <Gtk.Switch ref={grayscaleRef} halign="END" />,
              <p>Mirror</p>,
              <Gtk.Switch ref={mirrorRef} halign="END" />,
            ];

            for (let el of els) {
              ref.add(ref, el);
            }
          }}
        />

        <div spacing={10} hexpand>
          <button hexpand onClick={bgfn("reset")}>
            Apply
          </button>
          <button hexpand onClick={bgfn("rand")}>
            Rand Bg
          </button>
          <button
            hexpand
            onClick={() => {
              astal.exec_async(
                "bash -c 'rm -fr ~/.local/state/wallpaper-manager/* ~/Pictures/gowall' ",
                loadImg,
              );
            }}
          >
            Clean Image Cache
          </button>
        </div>

        <div spacing={9} className="p-2">
          <div spacing={10} vertical>
            <Image ref={nextImgRef} />
            <button onClick={bgfn("next")}>Next Bg</button>
          </div>
          <div spacing={10} vertical>
            <Image ref={prevImgRef} />
            <button onClick={bgfn("prev")}>Prev Bg</button>
          </div>
        </div>
        <hr />

        <button
          onClick={() =>
            astal.exec_async(
              "bash -c 'theme.sh dark & pgrep niri && niri msg action do-screen-transition --delay-ms 500'",
              () => ps.restart(),
            )
          }
        >
          Dark Mode
        </button>
        <button
          onClick={() =>
            astal.exec_async(
              "bash -c 'theme.sh light & pgrep niri && niri msg action do-screen-transition --delay-ms 500'",
              () => ps.restart(),
            )
          }
        >
          Light Mode
        </button>

        <Gtk.FlowBox
          max_children_per_line={7}
          selection_mode={"NONE"}
          margin={20}
          ref={(ref: any) => {
            Array.from({ length: 16 }, (_, i) => {
              const className = `base${i.toString(16).toUpperCase().padStart(2, "0")}`;
              return className;
            }).forEach((className) => {
              ref.add(
                ref,
                <eventbox
                  on_button_press_event={() => {
                    astal.exec_async(
                      `bash -c 'echo "${assets.colors[className]}" | cs; notify-send "Copied Color: ${assets.colors[className]}"'`,
                    );
                  }}
                >
                  <div
                    expand
                    className={"rounded-lg bg-" + className}
                    width={50}
                    height={50}
                    valign="CENTER"
                    halign="CENTER"
                  >
                    {className}
                  </div>
                </eventbox>,
              );
            });
          }}
        />
      </div>
    </scrollable>
  );
}

export default mkPopupToggleAnim(
  Center,
  {
    title: "Center",
    anchor: TOP + RIGHT + BOTTOM,
    class_name: "transparent",
    keymode: "ON_DEMAND",
  },
  {
    transition_type: Gtk.RevealerTransitionType.SLIDE_RIGHT,
  },
);
