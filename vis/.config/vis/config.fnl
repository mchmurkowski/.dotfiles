;; (set vis.ftdetect.filetypes.fennel.cmd ["set tw 2"
;;                                        "set et on"])

(fn vset [attrs]
  (each [k v (pairs attrs)]
    (vis:command (string.format "set %s %s" k v))))

(fn vsubscribe [event f]
  (let [actual-event (-> event
                         (: :upper)
                         (: :gsub "-" "_"))]
    (vis.events.subscribe (. vis.events actual-event) f)))

(vsubscribe :init
            (fn []
              (vset {:theme :base16-grayscale-dark})))

(vsubscribe :win-open
            (fn [win]
              (vset {:relativenumber :on})
              (vset {:autoindent :on})
              (vset {:tabwidth :4})
              (vset {:expandtab :on})
              (vset {:ignorecase :on})
              (vset {:showeof :off})
              (vset {:colorcolumn :88})))
