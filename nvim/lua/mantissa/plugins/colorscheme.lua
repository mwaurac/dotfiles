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
                highlight LineNr guibg=NONE guifg=#7aa2f7
                highlight CursorLineNr guibg=NONE guifg=#e0af68 gui=bold
                highlight EndOfBuffer guibg=NONE
            ]])
        end,
    },
}
