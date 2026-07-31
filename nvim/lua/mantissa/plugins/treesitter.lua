return {
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",

		opts = {
			ensure_installed = {
				"lua",
				"vim",
				"vimdoc",
				"query",
				"javascript",
				"typescript",
				"tsx",
				"html",
				"css",
				"json",
				"go",
				"rust",
				"c",
			},

			auto_install = true,

			highlight = {
				enable = true,
			},

			indent = {
				enable = true,
			},
		},
	},
}
