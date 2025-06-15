local lspconfig = require("lspconfig")

-- Gradle LSP
lspconfig.gradle_ls.setup({
  cmd = { "gradle-language-server" },
  filetypes = { "gradle", "groovy" },
  root_dir = lspconfig.util.root_pattern("settings.gradle", "build.gradle", ".git"),
})

-- Kotlin LSP
lspconfig.kotlin_language_server.setup({
  cmd = { "kotlin-language-server" },
  filetypes = { "kotlin" },
  root_dir = lspconfig.util.root_pattern(
    "settings.gradle.kts",
    "build.gradle.kts",
    "settings.gradle",
    "build.gradle",
    ".git"
  ),
})

-- Java LSP (JDTLS)
lspconfig.jdtls.setup({
  cmd = { "jdtls" },
  filetypes = { "java" },
  root_dir = lspconfig.util.root_pattern(".git", "mvnw", "gradlew", "pom.xml"),
})
