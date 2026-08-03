-- ============================================================
-- SECTION 9 // PLUGIN CONTROL
-- ============================================================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local filesystem = vim.uv or vim.loop

if not filesystem.fs_stat(lazypath) then
	local output = vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch=stable",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	})

	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to install lazy.nvim:\n", "ErrorMsg" },
			{ output, "WarningMsg" },
		}, true, {})

		error("lazy.nvim installation failed")
	end
end

vim.opt.rtp:prepend(lazypath)

local section9_theme = {
	normal = {
		a = { fg = "#050b12", bg = "#5bdaeb", gui = "bold" },
		b = { fg = "#c8d9e2", bg = "#153743" },
		c = { fg = "#c8d9e2", bg = "#0b1822" },
	},

	insert = {
		a = { fg = "#050b12", bg = "#50e6aa", gui = "bold" },
		b = { fg = "#c8d9e2", bg = "#153743" },
		c = { fg = "#c8d9e2", bg = "#0b1822" },
	},

	visual = {
		a = { fg = "#050b12", bg = "#a579d9", gui = "bold" },
		b = { fg = "#c8d9e2", bg = "#153743" },
		c = { fg = "#c8d9e2", bg = "#0b1822" },
	},

	replace = {
		a = { fg = "#050b12", bg = "#ff5b69", gui = "bold" },
		b = { fg = "#c8d9e2", bg = "#153743" },
		c = { fg = "#c8d9e2", bg = "#0b1822" },
	},

	command = {
		a = { fg = "#050b12", bg = "#f2b84b", gui = "bold" },
		b = { fg = "#c8d9e2", bg = "#153743" },
		c = { fg = "#c8d9e2", bg = "#0b1822" },
	},

	inactive = {
		a = { fg = "#4b6470", bg = "#071018" },
		b = { fg = "#4b6470", bg = "#071018" },
		c = { fg = "#4b6470", bg = "#071018" },
	},
}

require("lazy").setup({
	{
		"saghen/blink.cmp",
		version = "1.*",
		lazy = false,
		priority = 900,

		dependencies = {
			"rafamadriz/friendly-snippets",
		},

		opts = {
			-- keep your existing Blink options here
		},
	},

	{
		"neovim/nvim-lspconfig",
		lazy = false,

		dependencies = {
			"saghen/blink.cmp",
		},

		config = function()
			require("section9.lsp")
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").setup({
				install_dir = vim.fn.stdpath("data") .. "/site",
			})

			require("nvim-treesitter").install({
				"bash",
				"c",
				"cpp",
				"json",
				"lua",
				"python",
				"vim",
				"vimdoc",
			})
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter",

		-- The current plugin explicitly does not support lazy loading.
		lazy = false,

		-- Keep parsers compatible whenever the plugin is updated.
		build = ":TSUpdate",

		config = function()
			require("section9.treesitter")
		end,
	},

	{
		"folke/persistence.nvim",
		event = "BufReadPre",

		opts = {
			options = {
				"buffers",
				"curdir",
				"tabpages",
				"winsize",
				"help",
				"globals",
				"skiprtp",
			},
		},

		keys = {
			{
				"<leader>qs",
				function()
					require("persistence").load()
				end,
				desc = "Restore project session",
			},

			{
				"<leader>ql",
				function()
					require("persistence").load({
						last = true,
					})
				end,
				desc = "Restore last session",
			},

			{
				"<leader>qd",
				function()
					require("persistence").stop()
				end,
				desc = "Do not save session",
			},
		},
	},

	{
		"stevearc/overseer.nvim",

		cmd = {
			"OverseerRun",
			"OverseerToggle",
			"OverseerOpen",
			"OverseerClose",
			"OverseerBuild",
			"OverseerTaskAction",
			"OverseerRestartLast",
		},

		keys = {
			{
				"<leader>or",
				"<cmd>OverseerRun<cr>",
				desc = "Run task",
			},
			{
				"<leader>ot",
				"<cmd>OverseerToggle<cr>",
				desc = "Toggle task list",
			},
			{
				"<leader>oa",
				"<cmd>OverseerTaskAction<cr>",
				desc = "Task action",
			},
			{
				"<leader>ob",
				"<cmd>OverseerBuild<cr>",
				desc = "Create task",
			},
			{
				"<leader>ol",
				"<cmd>OverseerRestartLast<cr>",
				desc = "Restart last task",
			},
		},

		opts = {
			strategy = {
				"terminal",
				direction = "bottom",
				open_on_start = true,
				focus = false,
			},

			templates = {
				"builtin",
			},

			task_list = {
				direction = "bottom",
				min_height = 10,
				max_height = 18,

				render = function(task)
					return require("overseer.render").format_standard(task)
				end,

				bindings = {
					["?"] = "ShowHelp",
					["<CR>"] = "RunAction",
					["o"] = "Open",
					["q"] = "Close",
					["r"] = "Restart",
					["x"] = "Dispose",
				},
			},
		},
	},
	{
		"folke/trouble.nvim",
		cmd = "Trouble",

		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},

		opts = {
			focus = true,

			win = {
				position = "bottom",
				size = 12,
			},
		},

		keys = {
			{
				"<leader>xx",
				"<cmd>Trouble diagnostics toggle<cr>",
				desc = "Diagnostics",
			},
			{
				"<leader>xX",
				"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
				desc = "Buffer diagnostics",
			},
			{
				"<leader>xs",
				"<cmd>Trouble symbols toggle focus=false<cr>",
				desc = "Document symbols",
			},
			{
				"<leader>xl",
				"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
				desc = "LSP definitions/references",
			},
			{
				"<leader>xq",
				"<cmd>Trouble qflist toggle<cr>",
				desc = "Quickfix list",
			},
		},
	},

	{
		"akinsho/toggleterm.nvim",
		version = "*",

		keys = {
			{
				"<C-\\>",
				"<cmd>ToggleTerm<cr>",
				desc = "Toggle terminal",
			},
			{
				"<leader>tt",
				"<cmd>ToggleTerm direction=float<cr>",
				desc = "Floating terminal",
			},
			{
				"<leader>th",
				"<cmd>ToggleTerm direction=horizontal<cr>",
				desc = "Horizontal terminal",
			},
			{
				"<leader>tv",
				"<cmd>ToggleTerm direction=vertical size=50<cr>",
				desc = "Vertical terminal",
			},
		},

		opts = {
			size = function(term)
				if term.direction == "horizontal" then
					return 15
				end

				if term.direction == "vertical" then
					return math.floor(vim.o.columns * 0.35)
				end
			end,

			open_mapping = [[<C-\>]],
			hide_numbers = true,
			shade_terminals = false,
			start_in_insert = true,
			insert_mappings = true,
			terminal_mappings = true,
			persist_size = true,
			persist_mode = true,
			close_on_exit = true,
			shell = vim.o.shell,
			auto_scroll = true,
			direction = "float",

			float_opts = {
				border = "single",
				width = function()
					return math.floor(vim.o.columns * 0.82)
				end,
				height = function()
					return math.floor(vim.o.lines * 0.75)
				end,
				winblend = 0,
				title_pos = "center",
			},
		},
	},

	{
		"folke/which-key.nvim",
		event = "VeryLazy",

		opts = {
			preset = "modern",

			delay = 300,

			win = {
				border = "single",
				padding = { 1, 2 },
			},

			icons = {
				breadcrumb = "»",
				separator = "➜",
				group = "+",
			},
			spec = {
				{ "<leader>d", group = "Debug" },
				{ "<leader>h", group = "Git hunks" },
				{ "<leader>l", group = "LSP" },
				{ "<leader>f", group = "Find" },
				{ "<leader>e", desc = "File explorer" },
				{ "<leader>w", desc = "Save file" },
				{ "<leader>t", group = "Terminal" },
				{ "<leader>o", group = "Tasks" },
				{ "<leader>q", group = "Session/Quit" },
			},
		},
	},

	{
		"antosha417/nvim-lsp-file-operations",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-neo-tree/neo-tree.nvim",
		},
		config = true,
	},

	{
		"mfussenegger/nvim-dap",

		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
		},

		config = function()
			require("section9.dap")
		end,
	},

	{
		"nvim-telescope/telescope.nvim",
		version = "*",
		cmd = "Telescope",

		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
		},

		keys = {
			{
				"<leader>ff",
				"<cmd>Telescope find_files<CR>",
				desc = "S9: Find files",
			},
			{
				"<leader>fg",
				"<cmd>Telescope live_grep<CR>",
				desc = "S9: Search file contents",
			},
			{
				"<leader>fb",
				"<cmd>Telescope buffers<CR>",
				desc = "S9: Open buffers",
			},
			{
				"<leader>fr",
				"<cmd>Telescope oldfiles<CR>",
				desc = "S9: Recent files",
			},
			{
				"<leader>fh",
				"<cmd>Telescope help_tags<CR>",
				desc = "S9: Help interface",
			},
			{
				"<leader>gs",
				"<cmd>Telescope git_status<CR>",
				desc = "S9: Git status",
			},
		},

		config = function()
			require("section9.telescope")
		end,
	},
	{
		"goolord/alpha-nvim",
		event = "VimEnter",

		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},

		config = function()
			require("section9.dashboard")
		end,
	},

	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		cmd = "Neotree",

		keys = {
			{
				"<leader>e",
				"<cmd>Neotree toggle left reveal<cr>",
				desc = "Toggle file explorer",
			},
		},

		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-tree/nvim-web-devicons",
		},

		opts = {
			close_if_last_window = true,
			popup_border_style = "single",
			enable_git_status = true,
			enable_diagnostics = true,

			window = {
				position = "left",
				width = 32,

				mappings = {
					["<space>"] = "none",
					["l"] = "open",
					["h"] = "close_node",
					["<cr>"] = "open",
					["q"] = "close_window",
				},
			},

			filesystem = {
				follow_current_file = {
					enabled = true,
				},

				use_libuv_file_watcher = true,

				filtered_items = {
					visible = false,
					hide_dotfiles = false,
					hide_gitignored = true,
					hide_hidden = false,
				},
			},

			default_component_configs = {
				indent = {
					indent_size = 2,
					padding = 1,
					with_markers = true,
					indent_marker = "│",
					last_indent_marker = "└",
					expander_collapsed = "",
					expander_expanded = "",
				},

				icon = {
					folder_closed = "󰉋",
					folder_open = "󰝰",
					folder_empty = "󰉖",
				},

				git_status = {
					symbols = {
						added = "+",
						modified = "~",
						deleted = "-",
						renamed = "R",
						untracked = "?",
						ignored = "I",
						unstaged = "U",
						staged = "S",
						conflict = "!",
					},
				},
			},
		},
	},

	{
		"lewis6991/gitsigns.nvim",
		event = {
			"BufReadPre",
			"BufNewFile",
		},

		opts = {
			signs = {
				add = { text = "┃" },
				change = { text = "┃" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
				untracked = { text = "┆" },
			},

			signs_staged = {
				add = { text = "┃" },
				change = { text = "┃" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
				untracked = { text = "┆" },
			},

			current_line_blame = false,
			signcolumn = true,
			numhl = false,
			linehl = false,
			word_diff = false,

			preview_config = {
				border = "single",
				style = "minimal",
				relative = "cursor",
				row = 0,
				col = 1,
			},

			on_attach = function(buffer)
				local gs = package.loaded.gitsigns

				local function map(mode, lhs, rhs, description)
					vim.keymap.set(mode, lhs, rhs, {
						buffer = buffer,
						silent = true,
						desc = description,
					})
				end

				map("n", "]h", function()
					if vim.wo.diff then
						vim.cmd.normal({ "]c", bang = true })
					else
						gs.nav_hunk("next")
					end
				end, "Next Git hunk")

				map("n", "[h", function()
					if vim.wo.diff then
						vim.cmd.normal({ "[c", bang = true })
					else
						gs.nav_hunk("prev")
					end
				end, "Previous Git hunk")

				map({ "n", "v" }, "<leader>hs", gs.stage_hunk, "Stage hunk")
				map({ "n", "v" }, "<leader>hr", gs.reset_hunk, "Reset hunk")

				map("n", "<leader>hS", gs.stage_buffer, "Stage buffer")
				map("n", "<leader>hR", gs.reset_buffer, "Reset buffer")
				map("n", "<leader>hu", gs.undo_stage_hunk, "Undo staged hunk")

				map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
				map("n", "<leader>hb", gs.blame_line, "Blame current line")
				map("n", "<leader>hd", gs.diffthis, "Diff current file")
			end,
		},
	},

	{
		"stevearc/conform.nvim",
		event = {
			"BufWritePre",
		},
		cmd = {
			"ConformInfo",
		},

		keys = {
			{
				"<leader>lf",
				function()
					require("conform").format({
						async = true,
						lsp_format = "fallback",
					})
				end,
				mode = { "n", "v" },
				desc = "S9: Format file",
			},
		},

		opts = {
			formatters_by_ft = {
				c = { "clang_format" },
				cpp = { "clang_format" },

				lua = { "stylua" },
				python = { "black" },

				sh = { "shfmt" },
				bash = { "shfmt" },

				json = { "prettier" },
				jsonc = { "prettier" },
				yaml = { "prettier" },

				javascript = { "prettier" },
				javascriptreact = { "prettier" },
				typescript = { "prettier" },
				typescriptreact = { "prettier" },

				html = { "prettier" },
				css = { "prettier" },
				markdown = { "prettier" },
			},

			format_on_save = {
				timeout_ms = 1000,
				lsp_format = "fallback",
			},

			notify_on_error = true,
		},
	},

	{
		"nvim-tree/nvim-web-devicons",
		lazy = true,
	},

	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",

		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},

		opts = {
			options = {
				theme = section9_theme,

				icons_enabled = true,
				globalstatus = true,

				section_separators = {
					left = "",
					right = "",
				},

				component_separators = {
					left = " │ ",
					right = " │ ",
				},

				disabled_filetypes = {
					statusline = {
						"alpha",
						"lazy",
					},
				},
			},

			sections = {
				lualine_a = {
					{
						"mode",
						fmt = function(mode)
							return "S9 // " .. mode
						end,
					},
				},

				lualine_b = {
					{
						"branch",
						icon = "git:",
					},
					"diff",
				},

				lualine_c = {
					{
						"filename",
						path = 1,
						symbols = {
							modified = " ~",
							readonly = " RO",
							unnamed = "UNNAMED",
							newfile = " NEW",
						},
					},
				},

				lualine_x = {
					{
						"diagnostics",
						symbols = {
							error = "ERR:",
							warn = "WARN:",
							info = "INFO:",
							hint = "HINT:",
						},
					},
					"filetype",
				},

				lualine_y = {
					"progress",
				},

				lualine_z = {
					{
						"location",
						fmt = function(location)
							return "L:" .. location
						end,
					},
				},
			},

			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = {
					"filename",
				},
				lualine_x = {
					"location",
				},
				lualine_y = {},
				lualine_z = {},
			},
		},
	},
}, {
	change_detection = {
		notify = false,
	},
	rocks = {
		enabled = false,
	},
})
