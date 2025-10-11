local opt = vim.opt

vim.schedule(function()
  opt.clipboard = "unnamedplus"
end)

opt.breakindent = true
opt.completeopt = "menuone,noselect,fuzzy,nosort"
opt.confirm = true
opt.cursorline = true
opt.expandtab = true
opt.hlsearch = false
opt.ignorecase = true
opt.inccommand = "split"
opt.laststatus = 0
opt.linebreak = true
opt.number = true
opt.numberwidth = 4
opt.path:append(",**") -- use `:find` recursively
opt.relativenumber = true
opt.ruler = false
opt.scrolloff = 4
opt.shiftround = true
opt.shiftwidth = 0 -- 0 defaults to tabstop value
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
opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
opt.undofile = true
opt.updatetime = 250
opt.winbar = "%=%m %t" -- add topbar with file name and flag
opt.winborder = "single"
opt.wrap = false
