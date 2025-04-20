import { astal, Astal, Elements } from "../../../tslib/react";

const { mkPopupToggleAnim } = require("lua.utils.astal");
const { inspect, notify } = require("lua.utils.init");

const { exec_async, bind } = astal;

const AstalBluetooth = astal.require("AstalBluetooth");

export default function Bluetooth() {
  const bluetooth = AstalBluetooth.get_default();
  const devices = bind(bluetooth, "devices");
  const isPowered = bind(bluetooth, "is-powered");
  const isConnected = bind(bluetooth, "is-connected");

  return (
    <div vertical expand>
      <centerbox className="m-2">
        <p hexpand halign="START">
          Bluetooth
        </p>
        <p halign="END" className="px-2 m-2">
          {isConnected.as(isConnected, (isConnected: boolean) =>
            isConnected ? "Connected" : "None Connected",
          )}
        </p>
        <>
          {isPowered.as(isPowered, (isPowered: boolean) =>
            isPowered ? (
              <button onClick={() => bluetooth.toggle(bluetooth)}>
                Turn Off
              </button>
            ) : (
              <button onClick={() => bluetooth.toggle(bluetooth)}>
                Turn On
              </button>
            ),
          )}
        </>
      </centerbox>
      {isPowered.as(isPowered, (isPowered: boolean) =>
        !isPowered ? (
          <p>Not Powered</p>
        ) : (
          <scrollable hscroll="NEVER">
            <div vertical vexpand spacing={10}>
              {devices.as(devices, (devices: any[]) => {
                return devices.map((device) => {
                  const per = device["battery-percentage"];
                  const connected = bind(device, "connected");
                  return (
                    <centerbox hexpand>
                      <div halign="START" spacing={10}>
                        <icon icon={device.icon} />
                        {(per > 0 && (
                          <p className="text-base0B">{`${per * 100}%`}</p>
                        )) ||
                          null}
                        <p className="text-xl">
                          {(device.trusted && "\uebc1") || "\uebc2"}
                        </p>
                      </div>

                      <p hexpand>{device.name}</p>

                      <>
                        {connected.as(connected, (connected: boolean) => {
                          const connecting = bind(device, "connecting");
                          return (
                            <div halign="END">
                              {connected ? (
                                <button
                                  onClick={() =>
                                    device.disconnect_device(device)
                                  }
                                >
                                  Disconnect
                                </button>
                              ) : (
                                connecting.as(
                                  connecting,
                                  (connecting: boolean) =>
                                    connecting ? (
                                      <p>Connecting...</p>
                                    ) : (
                                      <button
                                        onClick={() =>
                                          device.connect_device(device)
                                        }
                                      >
                                        Connect
                                      </button>
                                    ),
                                )
                              )}
                            </div>
                          );
                        })}
                      </>
                    </centerbox>
                  );
                });
              })}
            </div>
          </scrollable>
        ),
      )}
    </div>
  );
}
