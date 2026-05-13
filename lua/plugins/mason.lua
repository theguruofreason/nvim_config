vim.pack.add({
    "https://www.github.com/mason-org/mason.nvim"
})
vim.cmd("packadd mason.nvim")

require("mason").setup({})
