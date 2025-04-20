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
  useCmd,
} from "../../../tslib/react";

const assets = require("lua.assets");
const json = require("dkjson");

// const { TOP, RIGHT, BOTTOM } = Astal.WindowAnchor;

const { mkPopupToggleAnim } = require("lua.utils.astal");
const { lastIndexOf, ninspect, notify } = require("lua.utils");

const { exec_async } = astal;

function SpotifyDashboard() {
  const user = useCmd("spotify.sh me", json.decode);
  const nowPlaying = useCmd("spotify.sh now_playing", json.decode);
  const playlists = useCmd("spotify.sh playlists 10 0", json.decode);
  const liked = useCmd("spotify.sh liked_songs 10 0", json.decode);
  const devices = useCmd("spotify.sh devices", json.decode);
  const topArtists = useCmd("spotify.sh top_artists 5 short_term", json.decode);
  const topTracks = useCmd("spotify.sh top_tracks 5 short_term", json.decode);

  return (
    <div
      vertical
      className="bg-base00-90 text-base05 p-6 rounded-lg"
      css={{ minWidth: "1080px", minHeight: "720px", overflow: "auto" }}
    >
      {/* 1. User Info */}
      <div className="text-xl mb-4">
        {user._v((u: any) =>
          u ? (
            <p>
              🎧 {u.display_name} ({u.product})
            </p>
          ) : (
            <Gtk.Spinner />
          ),
        )}
      </div>

      {/* 2. Playback Info */}
      <div spacing={2} className="my-4">
        {nowPlaying._v((np?: any) =>
          np && np.item ? (
            <div vertical>
              <p className="text-base0D">Now Playing:</p>
              <p>
                {np.item.name} —{" "}
                {np.item.artists.map((a: any) => a.name).join(", ")}
              </p>
              <div spacing={1} className="mt-2">
                <button
                  className="bg-base03 px-2 py-1 rounded"
                  onClick={() => exec_async("spotify.sh previous")}
                >
                  ⏮
                </button>
                <button
                  className="bg-base03 px-2 py-1 rounded"
                  onClick={() => exec_async("spotify.sh pause")}
                >
                  ⏸
                </button>
                <button
                  className="bg-base03 px-2 py-1 rounded"
                  onClick={() => exec_async("spotify.sh play")}
                >
                  ▶️
                </button>
                <button
                  className="bg-base03 px-2 py-1 rounded"
                  onClick={() => exec_async("spotify.sh next")}
                >
                  ⏭
                </button>
              </div>
            </div>
          ) : (
            <p>No track playing</p>
          ),
        )}
      </div>

      {/* 3. Devices */}
      <div className="my-4">
        <p className="text-base0D mb-2">Devices:</p>
        {devices._v((d?: { devices: any[] }) =>
          d && d.devices ? (
            d.devices.map((dev: any) => (
              <p>
                {dev.name} ({dev.type}) {dev.is_active ? "✅" : ""}
              </p>
            ))
          ) : (
            <p>No devices</p>
          ),
        )}
      </div>

      {/* 4. Playlists */}
      <div vertical className="my-4" spacing={10}>
        <p className="text-base0D">Playlists:</p>
        {playlists._v((pl?: { items: any[] }) =>
          pl && pl.items ? (
            pl.items.map((p: any) => (
              <button
                onClick={() =>
                  astal.exec("playerctl -p spotify_player open " + p.id)
                }
                className="cursor-pointer hover:text-base0A"
              >
                {p.name}
              </button>
            ))
          ) : (
            <Gtk.Spinner />
          ),
        )}
      </div>

      {/* 5. Liked Songs */}
      <div vertical className="my-4">
        <p className="text-base0D">Liked Songs:</p>
        {liked._v((lk?: { items?: any[] }) =>
          lk && lk.items ? (
            lk.items.map((t: any) => (
              <p>
                {t.track.name} —{" "}
                {t.track.artists.map((a: any) => a.name).join(", ")}
              </p>
            ))
          ) : (
            <Gtk.Spinner />
          ),
        )}
      </div>

      {/* 6. Top Artists / Tracks */}
      <div spacing={2} vertical className="my-4">
        <div>
          <p className="text-base0D">Top Artists:</p>
          {topArtists._v((ta?: { items: any[] }) =>
            ta && ta.items ? (
              ta.items.map((a: any) => <p>{a.name}</p>)
            ) : (
              <Gtk.Spinner />
            ),
          )}
        </div>
        <div className="mt-2">
          <p className="text-base0D">Top Tracks:</p>
          {topTracks._v((tt?: { items: any[] }) =>
            tt && tt.items ? (
              tt.items.map((t: any) => <p>{t.name}</p>)
            ) : (
              <Gtk.Spinner />
            ),
          )}
        </div>
      </div>
    </div>
  );
}

export default mkPopupToggleAnim(
  SpotifyDashboard,
  {
    title: "Spotify CLI UI",
    class_name: "transparent",
    keymode: "ON_DEMAND",
  },
  {
    transition_type: Gtk.RevealerTransitionType.SLIDE_RIGHT,
  },
);
