(local astal (require :astal))
(local Widget (require :astal.gtk3.widget))
(local {: Gtk} (require :astal.gtk3))

(local {:WindowAnchor Anchor} (astal.require :Astal))

(local {: range} (require :lua.utils))
(local {: mkPopupToggle} (require :lua.utils.astal))

(local {: btn : p : div : divv} (require :lua.extras.elements))
(local {: Grid} Gtk)

(fn datebtn [n]
  (div (btn n "p-1 m-1 bg-base01 hover-bg-base02 text-base06 rounded-md")))

(fn CalenderWindow []
  (Widget.Window {:title :Calender
                  :anchor Anchor.TOP
                  :class_name "w-12 h-12 bg-base00"
                  1 (divv [(div (Grid (icollect [_ v (ipairs (range 1 8))]
                                        (datebtn v)))
                                "w-12 h-12" nil)
                           (div (Grid (icollect [_ v (ipairs (range 8 16))]
                                        (datebtn v)))
                                "w-12 h-12" nil)
                           (div (Grid (icollect [_ v (ipairs (range 16 24))]
                                        (datebtn v)))
                                "w-12 h-12" nil)
                           (div (Grid (icollect [_ v (ipairs (range 24 32))]
                                        (datebtn v)))
                                "w-12 h-12" nil)
                           ;;
                           ])}))

(mkPopupToggle CalenderWindow)
