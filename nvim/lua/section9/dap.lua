local dap = require("dap")
local dapui = require("dapui")

-- ============================================================
-- SECTION 9 // DEBUG INTERFACE
-- ============================================================

dapui.setup({
	icons = {
		expanded = "▾",
		collapsed = "▸",
		current_frame = "▸",
	},

	controls = {
		enabled = true,
		element = "repl",
		icons = {
			pause = "Ⅱ",
			play = "▶",
			step_into = "↓",
			step_over = "→",
			step_out = "↑",
			step_back = "←",
			run_last = "↻",
			terminate = "■",
			disconnect = "×",
		},
	},

	layouts = {
		{
			elements = {
				{
					id = "scopes",
					size = 0.40,
				},
				{
					id = "breakpoints",
					size = 0.20,
				},
				{
					id = "stacks",
					size = 0.25,
				},
				{
					id = "watches",
					size = 0.15,
				},
			},
			position = "left",
			size = 40,
		},

		{
			elements = {
				{
					id = "repl",
					size = 0.60,
				},
				{
					id = "console",
					size = 0.40,
				},
			},
			position = "bottom",
			size = 12,
		},
	},

	floating = {
		border = "single",
	},
})

-- LLDB adapter
dap.adapters.lldb = {
	type = "executable",
	command = "lldb-dap",
	name = "lldb",
}

local function executable_path()
	return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/", "file")
end

dap.configurations.c = {
	{
		name = "Launch executable",
		type = "lldb",
		request = "launch",
		program = executable_path,
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
		args = {},
	},
}

dap.configurations.cpp = dap.configurations.c
dap.configurations.rust = dap.configurations.c

-- Open and close the interface automatically
dap.listeners.before.attach.section9_dapui = function()
	dapui.open()
end

dap.listeners.before.launch.section9_dapui = function()
	dapui.open()
end

dap.listeners.before.event_terminated.section9_dapui = function()
	dapui.close()
end

dap.listeners.before.event_exited.section9_dapui = function()
	dapui.close()
end

-- Debug signs
vim.fn.sign_define("DapBreakpoint", {
	text = "●",
	texthl = "DapBreakpoint",
	linehl = "",
	numhl = "",
})

vim.fn.sign_define("DapBreakpointCondition", {
	text = "◆",
	texthl = "DapBreakpointCondition",
	linehl = "",
	numhl = "",
})

vim.fn.sign_define("DapStopped", {
	text = "▶",
	texthl = "DapStopped",
	linehl = "DapStoppedLine",
	numhl = "",
})

-- Key mappings
vim.keymap.set("n", "<F5>", dap.continue, {
	desc = "Debug: Start or continue",
})

vim.keymap.set("n", "<F10>", dap.step_over, {
	desc = "Debug: Step over",
})

vim.keymap.set("n", "<F11>", dap.step_into, {
	desc = "Debug: Step into",
})

vim.keymap.set("n", "<F12>", dap.step_out, {
	desc = "Debug: Step out",
})

vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, {
	desc = "Debug: Toggle breakpoint",
})

vim.keymap.set("n", "<leader>dB", function()
	dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, {
	desc = "Debug: Conditional breakpoint",
})

vim.keymap.set("n", "<leader>dr", dap.repl.open, {
	desc = "Debug: Open REPL",
})

vim.keymap.set("n", "<leader>du", dapui.toggle, {
	desc = "Debug: Toggle interface",
})

vim.keymap.set("n", "<leader>dt", dap.terminate, {
	desc = "Debug: Terminate",
})

vim.keymap.set({ "n", "v" }, "<leader>dh", function()
	require("dap.ui.widgets").hover()
end, {
	desc = "Debug: Inspect value",
})
