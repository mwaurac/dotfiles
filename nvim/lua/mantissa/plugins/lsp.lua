return {
	--- LSP server configuration
	{
		"neovim/nvim-lspconfig",
	},

	-- install/manager lsp servers
	{
		"mason-org/mason.nvim",
		opts = {},
	},

	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = {
			"mason-org/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		opts = {
			ensure_installed = {
				"clangd",
				"rust_analyzer",
				"pyright",
				"lua_ls",
			},
		},
	},

	-- completion
	{
		"saghen/blink.cmp",
		version = "1.*",
		dependencies = {
			"L3MON4D3/LuaSnip",
		},
		opts = {
			completion = {
				auto_brackets = {
					enabled = true,
					kind_resolution = { "snippet", "function", "method" },
				},

				documentation = {
					auto_show = true,
				},
			},

			keymap = {
				preset = "default",
				["<Tab>"] = {
					function(cmp)
						if cmp.snippet_active() then
							return cmp.accept()
						else
							return cmp.select_and_accept()
						end
					end,
					"fallback",
				},
				["<S-Tab>"] = { "snippet_backward", "fallback" },
				["<C-j>"] = { "snippet_forward", "fallback" },
			},
			appearance = {
				nerd_font_variant = "mono",
			},

			completion = {
				documentation = {
					auto_show = true,
				},
			},

			sources = {
				default = {
					"lsp",
					"path",
					"snippets",
					"buffer",
				},
			},

			snippets = {
				preset = "luasnip",
			},
		},
	},

	{
		"L3MON4D3/LuaSnip",
		version = "v2.*",
	},

	-- Auto-close brackets/parens/braces while typing
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {
			check_ts = true,
		},
	},

	-- Formatting
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "ruff_format" },
				rust = { "rustfmt" },
				c = { "clang_format" },
				cpp = { "clang_format" },
			},

			format_on_save = {
				timeout_ms = 500,
				lsp_format = "fallback",
			},
		},
	},

	-- LSP progress notifications
	{
		"j-hui/fidget.nvim",
		opts = {},
	},

	{
		"neovim/nvim-lspconfig",

		config = function()
			local capabilities = require("blink.cmp").get_lsp_capabilities()

			-- C / C++
			vim.lsp.config("clangd", {
				capabilities = capabilities,
			})

			-- Rust
			vim.lsp.config("rust_analyzer", {
				capabilities = capabilities,

				settings = {
					["rust-analyzer"] = {
						check = {
							command = "clippy",
						},

						cargo = {
							allFeatures = true,
						},
					},
				},
			})

			-- Python
			vim.lsp.config("pyright", {
				capabilities = capabilities,
			})

			-- Lua / Neovim configuration
			vim.lsp.config("lua_ls", {
				capabilities = capabilities,

				settings = {
					Lua = {
						runtime = {
							version = "LuaJIT",
						},

						diagnostics = {
							globals = {
								"vim",
							},
						},

						workspace = {
							library = vim.api.nvim_get_runtime_file("", true),
							checkThirdParty = false,
						},

						telemetry = {
							enable = false,
						},
					},
				},
			})

			-- Enable them
			vim.lsp.enable({
				"clangd",
				"rust_analyzer",
				"pyright",
				"lua_ls",
			})

			-- Keymaps
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(event)
					local opts = { buffer = event.buf }

					vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
					vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
					vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
					vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)

					vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
					vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)

					vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
					vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

					vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
				end,
			})

			-- Diagnostics
			vim.diagnostic.config({
				virtual_text = true,

				signs = true,

				underline = true,

				severity_sort = true,

				float = {
					border = "rounded",
					source = "if_many",
				},
			})
		end,
	},
}
