-- ============================================================
-- SECTION 9 // NEOVIM INTERFACE
-- ============================================================

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Interface
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true
vim.opt.showmode = false
vim.opt.laststatus = 3
vim.opt.cmdheight = 1

-- Editing
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true
vim.opt.wrap = false

-- Searching
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true

-- Behavior
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 400

-- Neovide
if vim.g.neovide then
	vim.o.guifont = "JetBrainsMono Nerd Font:h11"

	vim.g.neovide_padding_top = 10
	vim.g.neovide_padding_bottom = 10
	vim.g.neovide_padding_left = 10
	vim.g.neovide_padding_right = 10

	vim.g.neovide_cursor_animation_length = 0.08
	vim.g.neovide_cursor_trail_size = 0.5
	vim.g.neovide_scroll_animation_length = 0.15
	vim.g.neovide_remember_window_size = true
end

-- Section 9 base colors
local colors = {
	background = "#050b12",
	foreground = "#c8d9e2",
	cyan = "#5bdaeb",
	cyan_bright = "#8af0fa",
	muted = "#4b6470",
	panel = "#0b1822",
	green = "#50e6aa",
	amber = "#f2b84b",
	red = "#ff5b69",
	blue = "#72a7ff",
	purple = "#a579d9",
}

vim.o.background = "dark"
vim.cmd.colorscheme("vim")
vim.g.colors_name = "section9"

local highlights = {
	Normal = { fg = colors.foreground, bg = colors.background },
	NormalFloat = { fg = colors.foreground, bg = colors.panel },
	FloatBorder = { fg = colors.cyan, bg = colors.panel },

	CursorLine = { bg = colors.panel },
	CursorLineNr = { fg = colors.cyan, bold = true },
	LineNr = { fg = colors.muted },

	Visual = { bg = "#153743" },
	Search = { fg = colors.background, bg = colors.amber },
	IncSearch = { fg = colors.background, bg = colors.cyan },

	Comment = { fg = colors.muted, italic = true },
	String = { fg = colors.green },
	Number = { fg = colors.amber },
	Boolean = { fg = colors.amber },
	Function = { fg = colors.cyan_bright },
	Identifier = { fg = colors.foreground },
	Keyword = { fg = colors.purple, bold = true },
	Type = { fg = colors.blue },
	Constant = { fg = colors.amber },

	Error = { fg = colors.red },
	WarningMsg = { fg = colors.amber },
	DiagnosticError = { fg = colors.red },
	DiagnosticWarn = { fg = colors.amber },
	DiagnosticInfo = { fg = colors.blue },
	DiagnosticHint = { fg = colors.cyan },

	StatusLine = { fg = colors.background, bg = colors.cyan },
	StatusLineNC = { fg = colors.muted, bg = colors.panel },

	Pmenu = { fg = colors.foreground, bg = colors.panel },
	PmenuSel = { fg = colors.background, bg = colors.cyan },

	Directory = { fg = colors.cyan },
	Title = { fg = colors.cyan, bold = true },
	MatchParen = { fg = colors.amber, bold = true },

	NeoTreeNormal = {
		fg = colors.foreground,
		bg = colors.background,
	},

	NeoTreeNormalNC = {
		fg = colors.foreground,
		bg = colors.background,
	},

	NeoTreeDirectoryName = {
		fg = colors.cyan,
	},

	NeoTreeDirectoryIcon = {
		fg = colors.cyan,
	},

	NeoTreeRootName = {
		fg = colors.cyan_bright,
		bold = true,
	},

	NeoTreeFileName = {
		fg = colors.foreground,
	},

	NeoTreeFileNameOpened = {
		fg = colors.cyan_bright,
		bold = true,
	},

	NeoTreeIndentMarker = {
		fg = colors.muted,
	},

	NeoTreeGitAdded = {
		fg = colors.green,
	},

	NeoTreeGitModified = {
		fg = colors.amber,
	},

	NeoTreeGitDeleted = {
		fg = colors.red,
	},

	NeoTreeGitUntracked = {
		fg = colors.cyan,
	},

	NeoTreeFloatBorder = {
		fg = colors.cyan,
		bg = colors.panel,
	},

	NeoTreeFloatTitle = {
		fg = colors.background,
		bg = colors.cyan,
		bold = true,
	},

	DapBreakpoint = {
		fg = colors.red,
	},

	DapBreakpointCondition = {
		fg = colors.amber,
	},

	DapStopped = {
		fg = colors.green,
		bold = true,
	},

	DapStoppedLine = {
		bg = "#153743",
	},

	DapUIVariable = {
		fg = colors.foreground,
	},

	DapUIScope = {
		fg = colors.cyan,
		bold = true,
	},

	DapUIType = {
		fg = colors.purple,
	},

	DapUIValue = {
		fg = colors.green,
	},

	DapUIModifiedValue = {
		fg = colors.amber,
		bold = true,
	},

	DapUIDecoration = {
		fg = colors.cyan,
	},

	DapUIThread = {
		fg = colors.green,
	},

	DapUIStoppedThread = {
		fg = colors.amber,
	},

	DapUIFrameName = {
		fg = colors.foreground,
	},

	DapUISource = {
		fg = colors.blue,
	},

	DapUILineNumber = {
		fg = colors.cyan,
	},

	DapUIFloatBorder = {
		fg = colors.cyan,
		bg = colors.panel,
	},

	DapUIWatchesEmpty = {
		fg = colors.red,
	},

	DapUIWatchesValue = {
		fg = colors.green,
	},

	DapUIWatchesError = {
		fg = colors.red,
	},

	WhichKey = {
		fg = colors.cyan,
	},

	WhichKeyGroup = {
		fg = colors.purple,
		bold = true,
	},

	WhichKeyDesc = {
		fg = colors.foreground,
	},

	WhichKeySeparator = {
		fg = colors.muted,
	},

	WhichKeyNormal = {
		fg = colors.foreground,
		bg = colors.panel,
	},

	WhichKeyBorder = {
		fg = colors.cyan,
		bg = colors.panel,
	},

	WhichKeyTitle = {
		fg = colors.background,
		bg = colors.cyan,
		bold = true,
	},

	TroubleNormal = {
		fg = colors.foreground,
		bg = colors.background,
	},

	TroubleNormalNC = {
		fg = colors.foreground,
		bg = colors.background,
	},

	TroubleCount = {
		fg = colors.background,
		bg = colors.cyan,
		bold = true,
	},

	TroubleText = {
		fg = colors.foreground,
	},

	TroubleSource = {
		fg = colors.muted,
	},

	TroubleFile = {
		fg = colors.cyan,
	},

	TroubleDirectory = {
		fg = colors.muted,
	},

	TroublePos = {
		fg = colors.blue,
	},

	TroubleIconError = {
		fg = colors.red,
	},

	TroubleIconWarn = {
		fg = colors.amber,
	},

	TroubleIconInfo = {
		fg = colors.blue,
	},

	TroubleIconHint = {
		fg = colors.cyan,
	},

	TroubleIndent = {
		fg = colors.muted,
	},

	ToggleTermNormal = {
		fg = colors.foreground,
		bg = colors.background,
	},

	ToggleTermNormalFloat = {
		fg = colors.foreground,
		bg = colors.panel,
	},

	ToggleTermFloatBorder = {
		fg = colors.cyan,
		bg = colors.panel,
	},

	ToggleTermFloatTitle = {
		fg = colors.background,
		bg = colors.cyan,
		bold = true,
	},
}

for group, settings in pairs(highlights) do
	vim.api.nvim_set_hl(0, group, settings)
end

for group, settings in pairs(highlights) do
	vim.api.nvim_set_hl(0, group, settings)
end

-- Section 9 Git colors
local git_highlights = {
	GitSignsAdd = {
		fg = "#50e6aa",
	},

	GitSignsChange = {
		fg = "#f2b84b",
	},

	GitSignsDelete = {
		fg = "#ff5b69",
	},

	GitSignsUntracked = {
		fg = "#5bdaeb",
	},

	GitSignsStagedAdd = {
		fg = "#287a62",
	},

	GitSignsStagedChange = {
		fg = "#8f6d2d",
	},

	GitSignsStagedDelete = {
		fg = "#8f3540",
	},
}

for group, settings in pairs(git_highlights) do
	vim.api.nvim_set_hl(0, group, settings)
end

-- Key mappings
vim.keymap.set("n", "<leader>w", "<cmd>write<cr>", {
	desc = "Save file",
})

vim.keymap.set("n", "<leader>qq", "<cmd>quit<cr>", {
	desc = "Quit window",
})

vim.keymap.set("n", "<leader>qQ", "<cmd>qa<cr>", {
	desc = "Quit Neovim",
})

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>")

-- Section 9 plugin control
require("section9.plugins")
