return {
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},

		keys = {
			{
				"<leader>e",
				"<cmd>NvimTreeToggle<cr>",
				desc = "Toggle file explorer",
			},
		},

		opts = {
			view = {
				width = 30,
			},
		},
	},
}