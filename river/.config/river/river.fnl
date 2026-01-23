(local colors {:background :0x6d8196
               :border :0x9f9f9f
               :border-focused :0x005e8b
               :border-unfocused :0xc2bcbb5
               :border-urgent :0xa60000
               :sl-init :0x2f4f4f
               :sl-input :0xa0e8af
               :sl-fail :0xffcf56})

(local scripts-dir (.. (os.getenv :XDG_CONFIG_HOME) :/river/scripts))

(local applications
       {:launcher :fuzzel
        :editor :emacs
        :term :alacritty
        :browser :firefox
        :screen-locker (string.format "'waylock -ignore-empty-password -init-color %s -input-color %s -fail-color %s'"
                                      (. colors :sl-init) (. colors :sl-input)
                                      (. colors :sl-fail))
        :power-menu (.. scripts-dir :/power_menu.sh)
        :time-teller (.. scripts-dir :/time_teller.sh)})

(fn rctl-set [setting value]
  "Set a setting to a value"
  (os.execute (string.format "riverctl %s %s" setting value)))

(fn rctl-spawn [command]
  "Spawn (run) a command at boot"
  (os.execute (string.format "riverctl spawn %s" command)))

(fn rctl-kbd-map [binding]
  "Takes a binding definition in form of a table (fields: lhs, rhs, ?mode) and setups the keyboard binding"
  (let [lhs (. binding :lhs)
        rhs (. binding :rhs)
        ?mode (. binding :mode)]
    (os.execute (string.format "riverctl map %s %s %s" (or ?mode :normal) lhs
                               rhs))))

(fn rctl-ptr-map [binding]
  "Takes a binding definition in form of a table (fields: lhs, rhs, ?mode) and setups the mouse binding"
  (let [lhs (. binding :lhs)
        rhs (. binding :rhs)
        ?mode (. binding :mode)]
    (os.execute (string.format "riverctl map-pointer %s %s %s"
                               (or ?mode :normal) lhs rhs))))

(fn rctl-add-rule [rule]
  "Takes a rule definition in form of a list and setups a rule"
  (os.execute (string.format "riverctl rule-add %s" (table.concat rule " "))))

(fn rconf []
  ;; interoperability
  (let [interop ["'dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=river'"
                 "'systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=river'"]]
    (each [_ command (ipairs interop)]
      (rctl-spawn command)))
  ;; settings
  (let [settings {:default-attach-mode :bottom
                  :default-layout :rivertile
                  :background-color (. colors :background)
                  :border-color (. colors :border)
                  :border-color-focused (. colors :border-focused)
                  :border-color-unfocused (. colors :border-unfocused)
                  :border-color-urgent (. colors :border-urgent)
                  :border-width :3
                  :focus-follows-cursor :normal
                  "hide-cursor timeout" :3000
                  "hide-cursor when-typing" :enabled
                  :keyboard-layout "-options 'ctrl:nocaps' 'pl'"
                  :set-cursor-warp :on-focus-change
                  :set-repeat "30 300"
                  :xcursor-theme :Hackneyed-24px}]
    (each [setting value (pairs settings)]
      (rctl-set setting value))
    (rctl-spawn (string.format "'gsettings set org.gnome.desktop.interface cursor-theme %s'"
                               (. settings :xcursor-theme))))
  ;; keybindings
  (let [bindings [{:lhs "Super Space"
                   :rhs (.. "spawn " (. applications :launcher))}
                  {:lhs "Super Return"
                   :rhs (.. "spawn " (. applications :term))}
                  {:lhs "Super+Shift Return"
                   :rhs (.. "spawn " (. applications :editor))}
                  {:lhs "Alt+Control L"
                   :rhs (.. "spawn " (. applications :screen-locker))}
                  {:lhs "Super+Shift Q"
                   :rhs (.. "spawn " (. applications :power-menu))}
                  {:lhs "Super T"
                   :rhs (.. "spawn " (. applications :time-teller))}
                  {:lhs "Super Esc" :rhs "spawn 'makoctl dissmiss'"}
                  {:lhs "Super Q" :rhs :close}
                  {:lhs "Super+Shift E" :rhs :exit}
                  {:lhs "Super O" :rhs :zoom}
                  {:lhs "Super F" :rhs :toggle-float}
                  {:lhs "Super+Shift F" :rhs :toggle-fullscreen}
                  {:lhs "Super J" :rhs "focus-view next"}
                  {:lhs "Super K" :rhs "focus-view previous"}
                  {:lhs "Super+Shift J" :rhs "swap next"}
                  {:lhs "Super+Shift K" :rhs "swap previous"}
                  {:lhs "Super H"
                   :rhs "send-layout-cmd rivertile 'main-ratio -0.05'"}
                  {:lhs "Super L"
                   :rhs "send-layout-cmd rivertile 'main-ratio +0.05'"}
                  {:lhs "Super+Shift H"
                   :rhs "send-layout-cmd rivertile 'main-count +1'"}
                  {:lhs "Super+Shift L"
                   :rhs "send-layout-cmd rivertile 'main-count -1'"}]]
    (each [_ binding (ipairs bindings)]
      (rctl-kbd-map binding)))
  (let [directions {:H [:left :horizontal :-100]
                    :J [:down :vertical :100]
                    :K [:up :vertical :-100]
                    :L [:right :horizontal :100]}]
    (each [key [direction plane value] (pairs directions)]
      (let [bindings [{:lhs (.. "Super+Alt " key)
                       :rhs (string.format "move %s 100" direction)}
                      {:lhs (.. "Super+Alt+Control " key)
                       :rhs (.. "snap " direction)}
                      {:lhs (.. "Super+Alt+Shift " key)
                       :rhs (string.format "resize %s %s" plane value)}]]
        (each [_ binding (ipairs bindings)]
          (rctl-kbd-map binding)))))
  (let [directions {:Up :top :Right :right :Down :bottom :Left :left}]
    (each [key direction (pairs directions)]
      (let [bindings [{:lhs (.. "Super+Alt+Shift " key)
                       :rhs (string.format "send-layout-cmd rivertile 'main-location %s'"
                                           direction)}]]
        (each [_ binding (ipairs bindings)]
          (rctl-kbd-map binding)))))
  ;; mouse button bindings
  (let [bindings [{:lhs "Super BTN_LEFT" :rhs :move-view}
                  {:lhs "Super BTN_RIGHT" :rhs :resize-view}
                  {:lhs "Super BTN_MIDDLE" :rhs :toggle-float}]]
    (each [_ binding (ipairs bindings)]
      (rctl-ptr-map binding)))
  ;; keybinds for tag selection
  (for [i 1 9]
    (let [tag (lshift 1 (- i 1))
          bindings [{:lhs (.. "Super " i) :rhs (.. "set-focused-tags " tag)}
                    {:lhs (.. "Super+Control " i)
                     :rhs (.. "set-view-tags " tag)}
                    {:lhs (.. "Super+Shift " i)
                     :rhs (.. "toggle-focused-tags " tag)}
                    {:lhs (.. "Super+Shift+Control " i)
                     :rhs (.. "toggle-view-tags " tag)}]]
      (each [_ binding (ipairs bindings)]
        (rctl-kbd-map binding))))
  ;; keybinds for all tags
  (let [tags (- (lshift 1 32) 1)
        bindings [{:lhs "Super 0" :rhs (.. "set-focused-tags " tags)}
                  {:lhs "Super+Shift 0" :rhs (.. "set-view-tags " tags)}]]
    (each [_ binding (ipairs bindings)]
      (rctl-kbd-map binding)))
  ;; rules
  (let [named-tags {:emacs (lshift 1 0)
                    :term (lshift 1 1)
                    :web (lshift 1 2)
                    :qgis (lshift 1 7)}
        rules {:default-to-ssd [:ssd]
               :qgis-use-csd ["-app-id 'QGIS 3'" :csd]
               :assign-emacs-tag ["-app-id 'emacs'"
                                  (.. "tags " (. named-tags :emacs))]
               :assign-term-tag ["-app-id 'Alacritty'"
                                 (.. "tags " (. named-tags :term))]
               :assign-web-tag ["-app-id 'firefox'"
                                (.. "tags " (. named-tags :web))]
               :assign-qgis-tag ["-app-id 'QGIS3'"
                                 (.. "tags " (. named-tags :qgis))]}]
    (each [_ rule (pairs rules)]
      (rctl-add-rule rule)))
  ;; autostart apps
  (let [autostart-apps [(. applications :editor)
                        (. applications :term)
                        (. applications :browser)]]
    (each [_ app (ipairs autostart-apps)]
      (rctl-spawn app)))
  ;; call rivertile
  (os.execute "rivertile -view-padding 4 -outer-padding 4 -main-ratio 0.5 &"))

(rconf)
