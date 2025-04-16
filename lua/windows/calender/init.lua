local astal = require("astal")
local Widget = require("astal.gtk3.widget")
local _local_1_ = require("astal.gtk3")
local Gtk = _local_1_["Gtk"]
local _local_2_ = astal.require("Astal")
local Anchor = _local_2_["WindowAnchor"]
local _local_3_ = require("lua.utils")
local range = _local_3_["range"]
local _local_4_ = require("lua.utils.astal")
local mkPopupToggle = _local_4_["mkPopupToggle"]
local _local_5_ = require("lua.extras.elements")
local btn = _local_5_["btn"]
local p = _local_5_["p"]
local div = _local_5_["div"]
local divv = _local_5_["divv"]
local Grid = Gtk["Grid"]
local function datebtn(n)
  return div(btn(n, "p-1 m-1 bg-base01 hover-bg-base02 text-base06 rounded-md"))
end
local function CalenderWindow()
  local function _6_()
    local tbl_21_ = {}
    local i_22_ = 0
    for _, v in ipairs(range(1, 8)) do
      local val_23_ = datebtn(v)
      if (nil ~= val_23_) then
        i_22_ = (i_22_ + 1)
        tbl_21_[i_22_] = val_23_
      else
      end
    end
    return tbl_21_
  end
  local function _8_()
    local tbl_21_ = {}
    local i_22_ = 0
    for _, v in ipairs(range(8, 16)) do
      local val_23_ = datebtn(v)
      if (nil ~= val_23_) then
        i_22_ = (i_22_ + 1)
        tbl_21_[i_22_] = val_23_
      else
      end
    end
    return tbl_21_
  end
  local function _10_()
    local tbl_21_ = {}
    local i_22_ = 0
    for _, v in ipairs(range(16, 24)) do
      local val_23_ = datebtn(v)
      if (nil ~= val_23_) then
        i_22_ = (i_22_ + 1)
        tbl_21_[i_22_] = val_23_
      else
      end
    end
    return tbl_21_
  end
  local function _12_()
    local tbl_21_ = {}
    local i_22_ = 0
    for _, v in ipairs(range(24, 32)) do
      local val_23_ = datebtn(v)
      if (nil ~= val_23_) then
        i_22_ = (i_22_ + 1)
        tbl_21_[i_22_] = val_23_
      else
      end
    end
    return tbl_21_
  end
  return Widget.Window({divv({div(Grid(_6_()), "w-12 h-12", nil), div(Grid(_8_()), "w-12 h-12", nil), div(Grid(_10_()), "w-12 h-12", nil), div(Grid(_12_()), "w-12 h-12", nil)}), title = "Calender", anchor = Anchor.TOP, class_name = "w-12 h-12 bg-base00"})
end
return mkPopupToggle(CalenderWindow)
