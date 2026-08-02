-- ============================================================
-- SECTION 9 // LANGUAGE INTELLIGENCE
-- ============================================================

local servers = {
	"clangd",
	"lua_ls",
	"pyright",
	"bashls",
	"jsonls",
	"yamlls",
}

local capabilities = vim.lsp.protocol.make_client_capabilities()

local blink_ok, blink = pcall(require, "blink.cmp")

if blink_ok then
	capabilities = blink.get_lsp_capabilities(capabilities)
else
	vim.schedule(function()
		vim.notify("blink.cmp is unavailable; using standard LSP capabilities", vim.log.levels.WARN)
	end)
end

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
				checkThirdParty = false,
				library = {
					vim.env.VIMRUNTIME,
				},
			},

			telemetry = {
				enable = false,
			},
		},
	},
})

vim.lsp.config("clangd", {
	cmd = {
		"clangd",
		"--background-index",
		"--clang-tidy",
		"--completion-style=detailed",
		"--header-insertion=iwyu",
	},
})

for _, server in ipairs(servers) do
	vim.lsp.config(server, {
		capabilities = capabilities,
	})

	vim.lsp.enable(server)
end

local group = vim.api.nvim_create_augroup("Section9Lsp", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
	group = group,

	callback = function(event)
		local opts = {
			buffer = event.buf,
			silent = true,
		}

		vim.keymap.set(
			"n",
			"gd",
			vim.lsp.buf.definition,
			vim.tbl_extend("force", opts, {
				desc = "Go to definition",
			})
		)

		vim.keymap.set(
			"n",
			"gD",
			vim.lsp.buf.declaration,
			vim.tbl_extend("force", opts, {
				desc = "Go to declaration",
			})
		)

		vim.keymap.set(
			"n",
			"gr",
			vim.lsp.buf.references,
			vim.tbl_extend("force", opts, {
				desc = "Find references",
			})
		)

		vim.keymap.set(
			"n",
			"K",
			vim.lsp.buf.hover,
			vim.tbl_extend("force", opts, {
				desc = "Hover documentation",
			})
		)

		vim.keymap.set(
			"n",
			"<leader>rn",
			vim.lsp.buf.rename,
			vim.tbl_extend("force", opts, {
				desc = "Rename symbol",
			})
		)

		vim.keymap.set(
			{ "n", "v" },
			"<leader>ca",
			vim.lsp.buf.code_action,
			vim.tbl_extend("force", opts, {
				desc = "Code action",
			})
		)

		vim.keymap.set(
			"n",
			"[d",
			vim.diagnostic.goto_prev,
			vim.tbl_extend("force", opts, {
				desc = "Previous diagnostic",
			})
		)

		vim.keymap.set(
			"n",
			"]d",
			vim.diagnostic.goto_next,
			vim.tbl_extend("force", opts, {
				desc = "Next diagnostic",
			})
		)

		vim.keymap.set(
			"n",
			"<leader>ld",
			vim.diagnostic.open_float,
			vim.tbl_extend("force", opts, {
				desc = "Show diagnostic",
			})
		)
	end,
})

vim.diagnostic.config({
	virtual_text = {
		prefix = "■",
		spacing = 2,
	},

	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,

	float = {
		border = "single",
		source = true,
		header = "SECTION 9 // DIAGNOSTIC",
	},
})

vim.api.nvim_set_hl(0, "DiagnosticError", {
	fg = "#ff5b69",
})

vim.api.nvim_set_hl(0, "DiagnosticWarn", {
	fg = "#f2b84b",
})

vim.api.nvim_set_hl(0, "DiagnosticInfo", {
	fg = "#72a7ff",
})

vim.api.nvim_set_hl(0, "DiagnosticHint", {
	fg = "#5bdaeb",
})

local completion_highlights = {
	BlinkCmpMenu = {
		fg = "#c8d9e2",
		bg = "#050b12",
	},

	BlinkCmpMenuBorder = {
		fg = "#5bdaeb",
		bg = "#050b12",
	},

	BlinkCmpMenuSelection = {
		fg = "#f3fbff",
		bg = "#153743",
		bold = true,
	},

	BlinkCmpLabel = {
		fg = "#c8d9e2",
	},

	BlinkCmpLabelMatch = {
		fg = "#5bdaeb",
		bold = true,
	},

	BlinkCmpLabelDeprecated = {
		fg = "#4b6470",
		strikethrough = true,
	},

	BlinkCmpSource = {
		fg = "#78909c",
	},

	BlinkCmpDoc = {
		fg = "#c8d9e2",
		bg = "#0b1822",
	},

	BlinkCmpDocBorder = {
		fg = "#294452",
		bg = "#0b1822",
	},

	BlinkCmpSignatureHelp = {
		fg = "#c8d9e2",
		bg = "#0b1822",
	},

	BlinkCmpSignatureHelpBorder = {
		fg = "#5bdaeb",
		bg = "#0b1822",
	},
}

for group, settings in pairs(completion_highlights) do
	vim.api.nvim_set_hl(0, group, settings)
end
