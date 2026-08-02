local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

dashboard.section.header.val = {
  "┌───────────────────────────────────────────┐",
  "│       SECTION 9 // COMMAND INTERFACE      │",
  "│                                           │",
  "│     PUBLIC SECURITY INTELLIGENCE NODE     │",
  "│            SYSTEM OPERATIONAL             │",
  "└───────────────────────────────────────────┘",
}

dashboard.section.buttons.val = {
  dashboard.button("e", "  NEW BUFFER", "<cmd>ene<CR>"),
  dashboard.button("f","  FILE INTERFACE","<cmd>Telescope find_files<CR>"),
  dashboard.button("c", "  EDIT CONFIG", "<cmd>edit ~/.config/nvim/init.lua<CR>"),
  dashboard.button("p", "  PLUGIN CONTROL", "<cmd>Lazy<CR>"),
  dashboard.button("q", "  TERMINATE SESSION", "<cmd>qa<CR>"),
}

dashboard.section.footer.val = {
  "SECURE CHANNEL ACTIVE // NODE AUTHENTICATED",
}

dashboard.config.layout = {
  { type = "padding", val = 4 },
  dashboard.section.header,
  { type = "padding", val = 2 },
  dashboard.section.buttons,
  { type = "padding", val = 2 },
  dashboard.section.footer,
}

alpha.setup(dashboard.config)

vim.api.nvim_set_hl(0, "AlphaHeader", {
  fg = "#5bdaeb",
  bold = true,
})

vim.api.nvim_set_hl(0, "AlphaButtons", {
  fg = "#c8d9e2",
})

vim.api.nvim_set_hl(0, "AlphaShortcut", {
  fg = "#50e6aa",
  bold = true,
})

vim.api.nvim_set_hl(0, "AlphaFooter", {
  fg = "#4b6470",
  italic = true,
})

dashboard.section.header.opts.hl = "AlphaHeader"
dashboard.section.buttons.opts.hl = "AlphaButtons"
dashboard.section.footer.opts.hl = "AlphaFooter"
