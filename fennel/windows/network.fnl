(local astal (require :astal))
(local {: bind} astal)
(local Widget (require :astal.gtk3.widget))
(local lgi (require :lgi))
(local Network (lgi.require :AstalNetwork))
(local Bluetooth (lgi.require :AstalBluetooth))
(local {:WindowAnchor Anchor} (astal.require :Astal))
(local {: inspect : range} (require :lua.utils))
(local {: mkPopupToggleAnim} (require :lua.utils.astal))

(local {: i : btni : btn : p : div : divv : grid}
       (require :lua.extras.elements))

(local {: Grid} (require :astal.gtk3))

(local {: tcss} (require :lua.extras.tailwind))

(fn Window []
  (local network (Network.get_default))
  (local bluetooth (Bluetooth.get_default))
  (div (divv [(div :Wifi "p-2 m-2 hover-bg-base0F" {:click_through true})
              (div network.wifi.ssid)
              (div :Bluetooth)
              (divv (icollect [_ v (ipairs bluetooth.devices)]
                      (grid [(i v.icon :p-1)
                             (p v.name nil {:hexpand true :halign :START})
                             ; (let [v (bind v
                             ;               :battery-percentage)]
                             ;   (v:as (fn [b]
                             ;           (if (> b 0)
                             ;               (p (.. (* 100 b)
                             ;                      "%")
                             ;                  :p-2)
                             ;               nil))))
                             (if v.connecting (p :Connecting)
                                 (if v.connected
                                     (btni :disc nil
                                           (fn []
                                             (v.disconnect)))
                                     (btni :conn nil (fn [] (v.connect)))))]
                            :p-2)))
              (div :Tether)])
       "rounded-lg bg-base00-90 m-2 p-2 border-solid border-base02 border-2 shadow"
       (tcss {:minWidth :30em})))

(mkPopupToggleAnim Window {:title :Network
                           :anchor (+ Anchor.RIGHT Anchor.TOP)
                           :class_name :transparent})
