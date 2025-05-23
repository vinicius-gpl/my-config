-- if true then return {} end -- NOTE: ADD THIS LINE TO INACTIVATE THIS FILE

---@type LazySpec
return {
  "AstroNvim/astrolsp",

  ---@param opts AstroLSPOpts ---@type AstroLSPOpts
  opts = function(_, opts)
    vim.list_extend(opts.servers or {}, {
      "lua_ls",
      "pylsp",
      "bashls",
      "ts_ls",
      "eslint",
      "marksman",
      "jsonls",
      "html",
      "cssls",
      "cmake",
      "jdtls",
    })

    opts.features = vim.tbl_extend("force", opts.features or {}, {
      codelens = true,
      inlay_hints = false,
      semantic_tokens = true,
    })

    opts.formatting = vim.tbl_extend("force", opts.formatting or {}, {
      format_on_save = {
        enabled = true,
        allow_filetypes = {},
        ignore_filetypes = {},
      },

      timeout_ms = 1000,
    })

    opts.config = require("astrocore").extend_tbl(opts.config or {}, {
      lua_ls = {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      },
      pylsp = {
        settings = {
          pylsp = {
            plugins = {
              pycodestyle = {
                ignore = { "W391" },
                maxLineLength = 100,
              },
            },
          },
        },
      },
      marksman = {},
      jdtls = {},
      bashls = {},
      ts_ls = {},
      eslint = {},
      jsonls = {},
      html = {},
      cssls = {},
      cmake = {},
    })

    opts.autocmds = opts.autocmds or {}
    opts.autocmds.lsp_codelens_refresh = {
      cond = "textDocument/codeLens",
      {
        event = { "InsertLeave", "BufEnter" },
        desc = "Refresh codelens (buffer)",
        callback = function(args)
          if require("astrolsp").config.features.codelens then vim.lsp.codelens.refresh { bufnr = args.buf } end
        end,
      },
    }

    return opts
  end,
}
