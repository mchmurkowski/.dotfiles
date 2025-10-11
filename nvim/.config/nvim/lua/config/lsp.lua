vim.lsp.enable({ "lua_ls", "jedi_language_server", "ruff" })

vim.diagnostic.config({
  virtual_lines = {
    current_line = true,
  },
})
