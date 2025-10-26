(fn augroup [name]
  (vim.api.nvim_create_augroup (.. "mch_" name) {"clear" true}))

(vim.api.nvim_create_autocmd ["FocusGained" "TermClose" "TermLeave"]
                             {"group" (augroup "reload_files")
                             "desc" "Reload files"
                             "callback" (fn []
                                            (if (not= vim.o.buftype "nofile")
                                                (vim.cmd "checktime")))})

(vim.api.nvim_create_autocmd "TextYankPost"
                             {"group" (augroup "highlight_yank")
                             "desc" "Highlight yanked text"
                             "callback" (fn []
                                          (vim.highlight.on_yank))})

(vim.api.nvim_create_autocmd "VimResized"
                             {"group" (augroup "resize_splits")
                             "desc" "Resize splits on window resize"
                             "callback" (fn []
                                          (local current_tab (vim.fn.tabpagenr))
                                          (vim.cmd "tabdo wincmd =")
                                          (vim.cmd (.. "tabnext" current_tab)))})

(vim.api.nvim_create_autocmd "FileType"
                             {"group" (augroup "wrap text")
                             "desc" "Wrap text in text buffers"
                             "pattern" ["gitcommit" "markdown"]
                             "callback" (fn []
                                          (set vim.opt_local.wrap true))})
