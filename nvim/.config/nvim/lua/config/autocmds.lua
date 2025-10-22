local function augroup(name)
  return vim.api.nvim_create_augroup("mch_" .. name, { clear = true })
end

vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("reload_files"),
  desc = "Reload files",
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  desc = "Highlight yanked text",
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd("VimResized", {
  group = augroup("resize_splits"),
  desc = "Resize splits on window resize",
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_text"),
  desc = "Wrap text for text buffers",
  pattern = { "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup("disable_highlight"),
  desc = "Disable syntax highlighting with Tree Sitter",
  callback = function()
    vim.cmd("TSToggle highlight")
  end,
})
