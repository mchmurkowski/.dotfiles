(local launcher-command :fuzzel)
(local terminal-command :alacritty)
(local scripts-dir (.. (os.getenv :XDG_CONFIG_HOME) :/river/scripts))
;; on change run `gsettings set org.gnome.desktop.interface cursor-theme [theme]`:
(local cursor-theme :Hackneyed-24px)
(local river-settings {:background-color :0x6d8196
                       :border-width :3
                       :border-color-focused :0x005e8b
                       :border-color-unfocused :0xc2bcb5
                       :keyboard-layout "-options 'ctrl:nocaps' 'pl'"
                       :set-repeat "30 300"
                       :xcursor-theme cursor-theme
                       :focus-follows-cursor :normal
                       :set-cursor-warp :on-focus-change
                       :default-attach-mode :bottom
                       :default-layout :rivertile})

(local rule-tags {:emacs (lshift 1 0)
                  :term (lshift 1 1)
                  :browser (lshift 1 2)
                  :qgis (lshift 1 7)})

(fn rctl-spawn [command]
  (os.execute (.. "riverctl spawn " command)))

(fn rctl-map [mapping]
  (local mode (. mapping :mode))
  (local lhs (. mapping :lhs))
  (local rhs (. mapping :rhs))
  (os.execute (.. "riverctl map " mode " " lhs " " rhs)))

(fn rctl-mouse-map [mapping]
  (local mode (. mapping :mode))
  (local lhs (. mapping :lhs))
  (local rhs (. mapping :rhs))
  (os.execute (.. "riverctl map-pointer " mode " " lhs " " rhs)))

(fn rctl-set [setting value]
  (os.execute (.. "riverctl " setting " " value)))

(fn rconf []
  ;; interoperability
  (rctl-spawn "'dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=river'")
  (rctl-spawn "'systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=river'")
  ;; mappings
  (rctl-map {:mode :normal
             :lhs "Super Space"
             :rhs (.. "spawn " launcher-command)})
  (rctl-map {:mode :normal
             :lhs "Super Return"
             :rhs (.. "spawn " terminal-command)})
  (rctl-map {:mode :normal
             :lhs "Super+Shift Return"
             :rhs "spawn 'emacsclient -c -e \"(eshell)\"'"})
  (rctl-map {:mode :normal
             :lhs "Super T"
             :rhs (.. "spawn " scripts-dir :/time_teller.sh)})
  (rctl-map {:mode :normal :lhs "Super Escape" :rhs "spawn 'makoctl dismiss'"})
  (rctl-map {:mode :normal :lhs "Super Q" :rhs :close})
  (rctl-map {:mode :normal
             :lhs "Super+Shift Q"
             :rhs (.. "spawn " scripts-dir :/power_menu.sh)})
  (rctl-map {:mode :normal :lhs "Super+Shift E" :rhs :exit})
  (rctl-map {:mode :normal
             :lhs "Alt+Control L"
             :rhs (.. "spawn "
                      "'waylock -ignore-empty-password -init-color 0x2F4F4F -input-color 0xA0E8AF -fail-color 0xFFCF56'")})
  (rctl-map {:mode :normal :lhs "Super O" :rhs :zoom})
  (rctl-map {:mode :normal :lhs "Super J" :rhs "focus-view next"})
  (rctl-map {:mode :normal :lhs "Super K" :rhs "focus-view previous"})
  (rctl-map {:mode :normal :lhs "Super+Shift J" :rhs "swap next"})
  (rctl-map {:mode :normal :lhs "Super+Shift K" :rhs "swap previous"})
  (rctl-map {:mode :normal
             :lhs "Super H"
             :rhs "send-layout-cmd rivertile 'main-ratio -0.05'"})
  (rctl-map {:mode :normal
             :lhs "Super L"
             :rhs "send-layout-cmd rivertile 'main-ratio +0.05'"})
  (rctl-map {:mode :normal
             :lhs "Super+Shift H"
             :rhs "send-layout-cmd rivertile 'main-count +1'"})
  (rctl-map {:mode :normal
             :lhs "Super+Shift J"
             :rhs "send-layout-cmd rivertile 'main-count -1'"})
  (rctl-map {:mode :normal :lhs "Super F" :rhs :toggle-float})
  (rctl-map {:mode :normal :lhs "Super+Shift F" :rhs :toggle-fullscreen})
  (let [directions {:H :left :J :down :K :up :L :right}]
    (each [key direction (pairs directions)]
      (rctl-map {:mode :normal
                 :lhs (.. "Super+Alt " key)
                 :rhs (.. "move " direction " 100")}))
    (each [key direction (pairs directions)]
      (rctl-map {:mode :normal
                 :lhs (.. "Super+Alt+Control " key)
                 :rhs (.. "snap " direction)})))
  (each [key direction (pairs {:H [:horizontal :-100]
                               :J [:vertical :100]
                               :K [:vertical :-100]
                               :L [:horizontal :100]})]
    (rctl-map {:mode :normal
               :lhs (.. "Super+Alt+Shift " key)
               :rhs (.. "resize " (. direction 1) " " (. direction 2))}))
  (let [directions {:Up :top :Right :right :Down :bottom :Left :left}]
    (each [key direction (pairs directions)]
      (rctl-map {:mode :normal
                 :lhs (.. "Super " key)
                 :rhs (.. "send-layout-cmd rivertile 'main-location " direction
                          "'")})))
  (rctl-mouse-map {:mode :normal :lhs "Super BTN_LEFT" :rhs :move-view})
  (rctl-mouse-map {:mode :normal :lhs "Super BTN_RIGHT" :rhs :resize-view})
  (rctl-mouse-map {:mode :normal :lhs "Super BTN_MIDDLE" :rhs :toggle-float})
  (for [i 1 9]
    (local tags (lshift 1 (- i 1)))
    (rctl-map {:mode :normal
               :lhs (.. "Super " i)
               :rhs (.. "set-focused-tags " tags)})
    (rctl-map {:mode :normal
               :lhs (.. "Super+Control " i)
               :rhs (.. "set-view-tags " tags)})
    (rctl-map {:mode :normal
               :lhs (.. "Super+Shift " i)
               :rhs (.. "toggle-focused-tags " tags)})
    (rctl-map {:mode :normal
               :lhs (.. "Super+Shift+Control " i)
               :rhs (.. "toggle-view-tags " tags)}))
  (local all-tags (- (lshift 1 32) 1))
  (rctl-map {:mode :normal
             :lhs "Super 0"
             :rhs (.. "set-focused-tags " all-tags)})
  (rctl-map {:mode :normal
             :lhs "Super+Shift 0"
             :rhs (.. "set-view-tags " all-tags)})
  ;; settings loop
  (each [setting value (pairs river-settings)]
    (rctl-set setting value))
  ;; rules
  (rctl-set :rule-add :ssd)
  (rctl-set :rule-add "-app-id 'QGIS3' csd")
  (rctl-set :rule-add (.. "-app-id 'emacs' tags " (. rule-tags :emacs)))
  (rctl-set :rule-add (.. "-app-id 'Alacritty' tags " (. rule-tags :term)))
  (rctl-set :rule-add (.. "-app-id 'firefox' tags " (. rule-tags :browser)))
  (rctl-set :rule-add (.. "-app-id 'QGIS3' tags " (. rule-tags :qgis)))
  ;; autostart applications
  (rctl-spawn :emacs)
  (rctl-spawn terminal-command)
  (rctl-spawn :firefox)
  ;; call rivertile
  (os.execute "rivertile -view-padding 4 -outer-padding 4 -main-ratio 0.5 &"))

(rconf)
