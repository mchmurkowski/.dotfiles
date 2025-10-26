(set vim.g.mapleader (vim.keycode :<Space>))
(set vim.g.maplocalleader (vim.keycode :<Slash>))

(local keymap vim.keymap)

;; better vertical movement
(keymap.set [:n :x] :j "v:count == 0 ? 'gj' : 'j'"
            {:desc :Down :expr true :silent true})
(keymap.set [:n :x] :k "v:count == 0 ? 'gk' : 'k'"
            {:desc :Up :expr true :silent true})

;; better indenting
(keymap.set :v "<" :<gv)
(keymap.set :v ">" :>gv)

;; center line on scrolling by page
(keymap.set :n :<C-d> :<C-d>zz)
(keymap.set :n :<C-u> :<C-u>zz)

;; center line with search result
(keymap.set :n :n :nzzzv)
(keymap.set :n :N :Nzzzv)

(keymap.set :n :<Leader>ff ":find " {:desc "Find files"})

;; buffers
(keymap.set :n :<Leader>bb ":buffer " {:desc "Switch buffers"})
(keymap.set :n :<Leader>bl :<Cmd>buffers<CR> {:desc "List buffers"})
(keymap.set :n :<Leader>bp :<Cmd>bprev<CR> {:desc "Previous buffer"})
(keymap.set :n :<Leader>bn :<Cmd>bnext<CR> {:desc "Next buffer"})
(keymap.set :n :<Leader>bx "<Cmd>e #<CR>" {:desc "Cycle buffers"})
(keymap.set :n :<Leader>bd :<Cmd>bd<CR> {:desc "Close buffer"})

(keymap.set [:n :i :x :s] :<C-s> :<Cmd>up<CR><Esc> {:desc "Save with Ctrl+s"})
