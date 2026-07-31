return {
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,

        config = function()
            vim.cmd.colorscheme("tokyonight")

            vim.cmd([[
                highlight Normal guibg=NONE
                highlight NormalFloat guibg=NONE
                highlight SignColumn guibg=NONE
                highlight LineNr guibg=NONE
                highlight CursorLineNr guibg=NONE
                highlight EndOfBuffer guibg=NONE
            ]])
        end,
    },
}
