return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },

  opts = {
    -- Habilita inlay hints (se o Neovim >= 0.10)
    inlay_hints = { enabled = true },
    servers = {
      -- Bash
      bashls = {},

      -- Docker compose
      docker_compose_language_service = {},

      -- Dockerfile
      dockerls = {},

      -- Erlang
      erlangls = {},

      -- Gradle
      gradle_ls = {},

      -- Json
      jsonls = {
        settings = {
          json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
          },
        },
      },

      -- Kotlin
      kotlin_language_server = {},

      -- Lua
      lua_ls = {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
            completion = { callSnippet = "Replace" },
          },
        },
      },

      -- Markdown
      marksman = {},

      -- Cmake
      neocmake = {},

      -- PHP
      phpactor = {},

      -- Python
      pyright = {
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "workspace",
            },
          },
          disableOrganizeImports = true,
        },
      },

      -- Tailwind CSS
      tailwindcss = {},

      -- TOML
      taplo = {},

      -- typescript
      vtsls = {
        settings = {
          typescript = {
            inlayHints = {
              parameterNames = { enabled = "all" },
              parameterTypes = { enabled = true },
              variableTypes = { enabled = true },
              propertyDeclarationTypes = { enabled = true },
              functionLikeReturnTypes = { enabled = true },
              enumMemberValues = { enabled = true },
            },
          },
        },
      },

      -- VUE
      volar = {},

      -- YAML
      yamlls = {
        settings = {
          yaml = {
            schemas = require("schemastore").yaml.schemas(),
          },
        },
      },
    },

    -- Configurações adicionais
    setup = {},
  },

  config = function(_, opts)
    -- Configurações do Mason

    -- Ferramentas de linting e formatação
    require("mason").setup({
      ensure_installed = {
        "cmakelint",
        "hadolint",
        "markdownlint-cli2",
        "ruff",
        "shellcheck",
        "sqlfluff",
        "ktlint",
        "phpcs",
        "cmake_format",
        "markdown_toc",
        "shfmt",
        "stylua",
        "ktfmt",
        "php_cs_fixer",
      },
    })

    -- LSP a ser instalados automaticamente
    require("mason-lspconfig").setup({
      ensure_installed = {
        "bashls",
        "docker_compose_language_service",
        "dockerls",
        "erlangls",
        "gradle_ls",
        "jsonls",
        "kotlin_language_server",
        "lua_ls",
        "marksman",
        "neocmake",
        "phpactor",
        "pyright",
        "tailwindcss",
        "taplo",
        "vtsls",
        "volar",
        "yamlls",
      },
      automatic_installation = true,
      handlers = {
        function(server_name)
          -- Configura cada servidor com as opções definidas em opts.servers
          require("lspconfig")[server_name].setup({
            settings = opts.servers[server_name] or {},
          })
        end,
      },
    })
  end,
}
