(local path-package (.. (vim.fn.stdpath :data) :/site/))
(local mini-path (.. path-package :pack/deps/start/mini.deps))
(if (not (vim.loop.fs_stat mini-path))
    (do
      (vim.cmd "echo 'Installing `mini.deps`' | redraw")
      (local clone-cmd [:git
                        :clone
                        "--filter=blob:none"
                        "https://github.com/nvim-mini/mini.deps"
                        mini-path])
      (vim.fn.system clone-cmd)
      (vim.cmd "packadd mini.deps | helptags ALL")
      (vim.cmd "echo 'Installed `mini.deps`' | redraw")))

(local deps (require :mini.deps))
(deps.setup {:path {:package path-package}})

(local add MiniDeps.add)

(add :miikanissi/modus-themes.nvim)
(local modus-themes (require :modus-themes))
(modus-themes.setup {:variant :tinted :styles {:keywords {:italic false}}})
(vim.cmd "colorscheme modus")

(add {:source :nvim-treesitter/nvim-treesitter
      :checkout :master
      :monitor :main
      :hooks {:post_checkout (fn [] (vim.cmd :TSUpdate))}})

(add {:source :nvim-mini/mini.completion :depends [:nvim-mini/mini.icons]})

(add :nvim-mini/mini.diff)

(add :nvim-mini/mini.pick)

(add :nvim-mini/mini.comment)

(add :nvim-mini/mini.clue)

(add :stevearc/conform.nvim)

(local treesitter-configs (require :nvim-treesitter.configs))
(treesitter-configs.setup {:ensure_installed [:python :lua :fennel :vimdoc]
                           :sync_install false
                           :auto_install false
                           :highlight {:enable true
                                       :additional_vim_regex_highlighting false}})

(local mini-icons (require :mini.icons))
(mini-icons.setup {:style :ascii})

(local mini-diff (require :mini.diff))
(mini-diff.setup)

(local mini-pick (require :mini.pick))
(mini-pick.setup (vim.keymap.set :n :<Leader>bb ":Pick buffers<CR>"
                                 {:desc "Switch buffers"})
                 (vim.keymap.set :n :<Leader>ff ":Pick files<CR>"
                                 {:desc "Find files"})
                 (vim.keymap.set :n :<Leader>hh ":Pick help<CR>"
                                 {:desc "Search help"})
                 (vim.keymap.set :n :<Leader>ss ":Pick grep_live<CR>"
                                 {:desc "Grep search"}))

(local mini-completion (require :mini.completion))
(mini-completion.setup)

(local conform (require :conform))
(conform.setup {:formatters_by_ft {:lua [:stylua]
                                   :python [:ruff_organize_imports
                                            :ruff_format]
                                   :fnl [:fnlfmt]}
                :format_on_save {:timeout_ms 500 :lsp_format :fallback}})

(local mini-comment (require :mini.comment))
(mini-comment.setup)

(local mini-clue (require :mini.clue))
(mini-clue.setup {:triggers [{:mode :n :keys :<Leader>}
                             {:mode :x :keys :<Leader>}
                             {:mode :i :keys :<C-x>}
                             {:mode :n :keys :g}
                             {:mode :x :keys :g}
                             {:mode :n :keys "'"}
                             {:mode :n :keys "`"}
                             {:mode :x :keys "'"}
                             {:mode :x :keys "`"}
                             ; {:mode :n :keys "\""}
                             ; {:mode :x :keys "\""}
                             {:mode :i :keys :<C-r>}
                             {:mode :c :keys :<C-r>}
                             {:mode :n :keys :<C-w>}
                             {:mode :n :keys :z}
                             {:mode :c :keys :z}
                             {:mode :n :keys "["}
                             {:mode :n :keys "]"}]
                  :clues [(mini-clue.gen_clues.builtin_completion)
                          (mini-clue.gen_clues.g)
                          (mini-clue.gen_clues.marks)
                          (mini-clue.gen_clues.registers)
                          (mini-clue.gen_clues.windows)
                          (mini-clue.gen_clues.z)]})
