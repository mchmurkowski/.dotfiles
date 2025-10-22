vim.lsp.enable({ "lua_ls", "basedpyright", "ruff" })

vim.diagnostic.config({
  virtual_lines = {
    current_line = true,
  },
})
