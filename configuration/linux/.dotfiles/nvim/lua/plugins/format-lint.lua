return {
  -- Configuração do conform.nvim (formatação)
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        cmake = { "cmake_format" },
        markdown = { "markdown_toc" },
        sh = { "shfmt" },
        lua = { "stylua" },
        kotlin = { "ktfmt" },
        php = { "php_cs_fixer" },
        python = { "ruff_format" },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    },
  },

  -- Configuração do nvim-lint (linting)
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        cmake = { "cmakelint" },
        dockerfile = { "hadolint" },
        markdown = { "markdownlint" },
        python = { "ruff" },
        sh = { "shellcheck" },
        sql = { "sqlfluff" },
        kotlin = { "ktlint" },
        php = { "phpcs" },
      },
      linters = {
        sqlfluff = {
          args = { "--dialect", "postgres" },
        },
      },
    },
  },
}
