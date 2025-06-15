-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- PowerShell como terminal
vim.keymap.set("n", "<leader>ft", "<cmd>ToggleTerm<CR>", { desc = "Abrir (pswh)" })

-- Ctrl+C copia a seleção (equivalente ao 'y' visual)
vim.api.nvim_set_keymap("v", "<C-c>", "y", { noremap = true, silent = true })

-- Ctrl+V cola no modo normal (já mapeado acima), mas se quiser colar no visual:
vim.api.nvim_set_keymap("v", "<C-v>", "p", { noremap = true, silent = true })
