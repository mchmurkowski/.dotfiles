local opt = vim.opt
local function set_clipboard()
  opt.clipboard = "unnamedplus"
  return nil
end
vim.schedule(set_clipboard)
opt.breakindent = true
opt.completeopt = "menuone,noselect,fuzzy,nosort"
opt.confirm = true
opt.cursorline = true
opt.expandtab = true
opt.hlsearch = false
opt.ignorecase = true
opt.laststatus = 0
opt.linebreak = true
opt.number = true
opt.numberwidth = 3
opt.relativenumber = true
opt.ruler = false
opt.scrolloff = 4
opt.shiftround = true
opt.shiftwidth = 0
opt.showmode = false
opt.sidescrolloff = 6
opt.signcolumn = "yes:2"
opt.smartcase = true
opt.smartindent = true
opt.smoothscroll = true
opt.splitbelow = true
opt.splitkeep = "screen"
opt.splitright = true
opt.swapfile = false
opt.tabstop = 4
opt.termguicolors = true
opt.timeoutlen = 300
opt.undodir = (os.getenv("HOME") .. "/.vim/undodir")
opt.undofile = true
opt.updatetime = 250
opt.winbar = "%=%m %t"
opt.winborder = "single"
opt.wrap = false
return nil
