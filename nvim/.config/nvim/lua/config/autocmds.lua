local function augroup(name)
  return vim.api.nvim_create_augroup(("mch_" .. name), {clear = true})
end
local function _1_()
  if (vim.o.buftype ~= "nofile") then
    return vim.cmd("checktime")
  else
    return nil
  end
end
vim.api.nvim_create_autocmd({"FocusGained", "TermClose", "TermLeave"}, {group = augroup("reload_files"), desc = "Reload files", callback = _1_})
local function _3_()
  return vim.highlight.on_yank()
end
vim.api.nvim_create_autocmd("TextYankPost", {group = augroup("highlight_yank"), desc = "Highlight yanked text", callback = _3_})
local function _4_()
  local current_tab = vim.fn.tabpagenr()
  vim.cmd("tabdo wincmd =")
  return vim.cmd(("tabnext" .. current_tab))
end
vim.api.nvim_create_autocmd("VimResized", {group = augroup("resize_splits"), desc = "Resize splits on window resize", callback = _4_})
local function _5_()
  vim.opt_local.wrap = true
  return nil
end
return vim.api.nvim_create_autocmd("FileType", {group = augroup("wrap text"), desc = "Wrap text in text buffers", pattern = {"gitcommit", "markdown"}, callback = _5_})
