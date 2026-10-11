return {
  "akinsho/toggleterm.nvim",
  opts = function()
    local shell = vim.fn.has("win32") == 1 and "pwsh" or "fish"

    return {
      shell = shell,
      direction = "horizontal",
    }
  end,
}
