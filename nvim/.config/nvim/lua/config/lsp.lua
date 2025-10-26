vim.lsp.enable({"lua_ls", "fennel_ls", "basedpyright", "ruff"})
return vim.diagnostic.config({virtual_lines = {current_line = true}})
