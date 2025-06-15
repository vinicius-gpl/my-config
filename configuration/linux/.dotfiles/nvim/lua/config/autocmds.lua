-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("Neotree_start_directory", { clear = true }),
  desc = "Start Neo-tree with directory",
  once = true,
  callback = function()
    if package.loaded["neo-tree"] then
      return
    end

    local argv = vim.fn.argv()
    if type(argv) == "string" then
      argv = { argv }
    end

    if not argv or vim.tbl_isempty(argv) then
      return
    end

    local path = argv[1]
    if type(path) ~= "string" or path == "" then
      return
    end

    local stats = vim.uv.fs_stat(path)
    if stats and stats.type == "directory" then
      require("neo-tree")
    end
  end,
})
