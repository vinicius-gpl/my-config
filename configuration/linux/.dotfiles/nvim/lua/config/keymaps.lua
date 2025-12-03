-- PowerShell como terminal
vim.keymap.set("n", "<leader>ft", "<cmd>ToggleTerm<CR>", { desc = "Abrir (pswh)" })

-- Ctrl+C copia a seleção (equivalente ao 'y' visual)
vim.api.nvim_set_keymap("v", "<C-c>", "y", { noremap = true, silent = true })

-- Ctrl+V cola no modo normal (já mapeado acima), mas se quiser colar no visual:
vim.api.nvim_set_keymap("v", "<C-v>", "p", { noremap = true, silent = true })
