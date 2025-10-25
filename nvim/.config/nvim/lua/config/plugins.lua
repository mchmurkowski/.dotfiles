local path_package = vim.fn.stdpath("data") .. "/site/"
local mini_path = path_package .. "pack/deps/start/mini.deps"
if not vim.loop.fs_stat(mini_path) then
  vim.cmd("echo 'Installing `mini.deps`' | redraw")
  local clone_cmd = {
    "git", "clone", "--filter=blob:none",
    "https://github.com/nvim-mini/mini.deps", mini_path
  }
  vim.fn.system(clone_cmd)
  vim.cmd("packadd mini.deps | helptags ALL")
  vim.cmd("echo 'Installed `mini.deps`' | redraw")
end

require("mini.deps").setup({ path = { package = path_package } })

local add = MiniDeps.add

add("miikanissi/modus-themes.nvim")
require ("modus-themes").setup({
  variant = "tinted",
  styles = {
    keywords = { italic = false },
  },
})
vim.cmd("colorscheme modus")

add({
  source = "nvim-treesitter/nvim-treesitter",
  checkout = "master",
  monitor = "main",
  hooks = { post_checkout = function() vim.cmd('TSUpdate') end },
})

add({
  source = "nvim-mini/mini.completion",
  depends = {
    "nvim-mini/mini.icons",
  }
})

add("nvim-mini/mini.files")

add("nvim-mini/mini.comment")

add("nvim-mini/mini.clue")

require("nvim-treesitter.configs").setup({
  ensure_installed = { "python", "lua", "fennel", "vimdoc" },
  sync_install = false,
  auto_install = false,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false
  }
})

require("mini.icons").setup({
  style = "ascii"
})

require("mini.files").setup()

require("mini.completion").setup()

require("mini.comment").setup()

require("mini.clue").setup({
  triggers = {
    -- Leader triggers
    { mode = "n", keys = "<Leader>" },
    { mode = "x", keys = "<Leader>" },

    -- Built-in completion
    { mode = "i", keys = "<C-x>" },

    -- `g` key
    { mode = "n", keys = "g" },
    { mode = "x", keys = "g" },

    -- Marks
    { mode = "n", keys = "'" },
    { mode = "n", keys = "`" },
    { mode = "x", keys = "'" },
    { mode = "x", keys = "`" },

    -- Registers
    { mode = "n", keys = '"' },
    { mode = "x", keys = '"' },
    { mode = "i", keys = "<C-r>" },
    { mode = "c", keys = "<C-r>" },

    -- Window commands
    { mode = "n", keys = "<C-w>" },

    -- `z` key
    { mode = "n", keys = "z" },
    { mode = "x", keys = "z" },

    -- bracket navigation
    { mode = "n", keys = "[" },
    { mode = "n", keys = "]" },
  },

  clues = {
    require("mini.clue").gen_clues.builtin_completion(),
    require("mini.clue").gen_clues.g(),
    require("mini.clue").gen_clues.marks(),
    require("mini.clue").gen_clues.registers(),
    require("mini.clue").gen_clues.windows(),
    require("mini.clue").gen_clues.z(),
  },
})
