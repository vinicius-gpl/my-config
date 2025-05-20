-- if true then return {} end -- NOTE: REMOVE THIS LINE TO INACTIVATE THIS FILE

---@type LazySpec
return {
  "AstroNvim/astroui",

  ---@param opts AstroUIOpts ---@type AstroUIOpts
  opts = function(_, opts)
    opts.colorscheme = "astrodark"

    opts.highlights = vim.tbl_extend("force", opts.highlights or {}, {
      -- init = {
      --   Normal = {
      --     bg = "#000000",
      --   },
      -- },
      -- astrodark = {
      --   -- Normal = {
      --   --   bg = "#000000",
      --   -- },
      -- },
    })

    opts.icons = vim.tbl_extend("force", opts.icons or {}, {
      LSPLoading1 = "⠋",
      LSPLoading2 = "⠙",
      LSPLoading3 = "⠹",
      LSPLoading4 = "⠸",
      LSPLoading5 = "⠼",
      LSPLoading6 = "⠴",
      LSPLoading7 = "⠦",
      LSPLoading8 = "⠧",
      LSPLoading9 = "⠇",
      LSPLoading10 = "⠏",
    })

    return opts
  end,
}
