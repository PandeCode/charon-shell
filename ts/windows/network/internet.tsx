import { astal, Astal, Elements } from "../../../tslib/react";

import Bluetooth from "./bluetooth";

const { mkPopupToggleAnim } = require("lua.utils.astal");
const { inspect, notify } = require("lua.utils.init");

const { exec_async, bind } = astal;

const Network = astal.require("AstalNetwork");
const AstalBluetooth = astal.require("AstalBluetooth");

export default function Internet() {
  const network = Network.get_default();

  const connectivity = bind(network, "connectivity"); // "UNKNOWN" | "NONE" | "PORTAL" | "LIMITED" | "FULL"
  const state = bind(network, "state");

  const wired = bind(network, "wired");
  const wifi = bind(network, "wifi");

  const scanning = bind(network.wifi, "scanning");
  const enabled = bind(network.wifi, "enabled");

  const iconName = bind(network.wifi, "icon-name");
  const aps = bind(network.wifi, "access-points");

  return (
    <div vertical>
      Network
      {connectivity}
      {state}
      {wired.as(wired, (wired: any) => {
        const iconName = bind(wired, "icon-name");

        if (wired.state == "UNAVAILABLE") return null;
        else
          return (
            <div vertical expand>
              <hr />
              WIRED
              <div vertical>
                {iconName.as(iconName, (iconName: string) => (
                  <icon icon={iconName} />
                ))}
                {wired.device}
                {wired.speed}
                {wired.state}
                {wired.internet}
              </div>
            </div>
          );
      })}
      <hr />
      <>
        {iconName.as(iconName, (iconName: string) => (
          <icon icon={iconName} />
        ))}
        <p className="text-2xl p-2" justify="CENTER" hexpand>
          WIFI
        </p>
      </>
      {scanning.as(scanning, (scanning: boolean) =>
        scanning ? (
          <p>Scanning...</p>
        ) : (
          <button onClick={() => wifi.scan(wifi)}>Scan</button>
        ),
      )}
      {enabled.as(enabled, (enabled: boolean) => {
        if (!enabled) {
          return <p>Disabled</p>;
        } else {
          return (
            <scrollable expand hscroll="NEVER">
              <div vertical>
                {aps.as(aps, (_aps: any[]) => {
                  return _aps.map((ap: any) => {
                    const _iconName = bind(ap, "icon-name");
                    return (
                      <div
                        spacing={10}
                        className="bg-base01 m-2 p-2 rounded-lg shadow"
                      >
                        {_iconName.as(_iconName, (__iconName: string) => (
                          <icon icon={__iconName} />
                        ))}
                        {ap.ssid}
                        {/* {ap.bandwidth} */}
                        {/* {ap.frequency} */}
                        {/* {ap.strength} */}
                        {/* {ap["last-seen"]} */}
                      </div>
                    );
                  });
                })}
              </div>
            </scrollable>
          );
        }
      })}
    </div>
  );
}
