local astal = require("astal")
local bind = astal["bind"]
local Widget = require("astal.gtk3.widget")
local lgi = require("lgi")
local Network = lgi.require("AstalNetwork")
local Bluetooth = lgi.require("AstalBluetooth")
local _local_1_ = astal.require("Astal")
local Anchor = _local_1_["WindowAnchor"]
local _local_2_ = require("lua.utils")
local inspect = _local_2_["inspect"]
local range = _local_2_["range"]
local _local_3_ = require("lua.utils.astal")
local mkPopupToggleAnim = _local_3_["mkPopupToggleAnim"]
local _local_4_ = require("lua.extras.elements")
local i = _local_4_["i"]
local btni = _local_4_["btni"]
local btn = _local_4_["btn"]
local p = _local_4_["p"]
local div = _local_4_["div"]
local divv = _local_4_["divv"]
local grid = _local_4_["grid"]
local _local_5_ = require("astal.gtk3")
local Grid = _local_5_["Grid"]
local _local_6_ = require("lua.extras.tailwind")
local tcss = _local_6_["tcss"]
local function Window()
  local network = Network.get_default()
  local bluetooth = Bluetooth.get_default()
  local function _7_()
    local tbl_21_ = {}
    local i_22_ = 0
    for _, v in ipairs(bluetooth.devices) do
      local val_23_
      local function _11_()
        if v.connecting then
          return p("Connecting")
        else
          if v.connected then
            local function _8_()
              return v.disconnect()
            end
            return btni("disc", nil, _8_)
          else
            local function _9_()
              return v.connect()
            end
            return btni("conn", nil, _9_)
          end
        end
      end
      val_23_ = grid({i(v.icon, "p-1"), p(v.name, nil, {hexpand = true, halign = "START"}), _11_()}, "p-2")
      if (nil ~= val_23_) then
        i_22_ = (i_22_ + 1)
        tbl_21_[i_22_] = val_23_
      else
      end
    end
    return tbl_21_
  end
  return div(divv({div("Wifi", "p-2 m-2 hover-bg-base0F", {click_through = true}), div(network.wifi.ssid), div("Bluetooth"), divv(_7_()), div("Tether")}), "rounded-lg bg-base00-90 m-2 p-2 border-solid border-base02 border-2 shadow", tcss({minWidth = "30em"}))
end
return mkPopupToggleAnim(Window, {title = "Network", anchor = (Anchor.RIGHT + Anchor.TOP), class_name = "transparent"})
