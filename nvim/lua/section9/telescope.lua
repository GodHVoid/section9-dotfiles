-- ============================================================
-- SECTION 9 // SEARCH INTERFACE
-- ============================================================

local telescope = require("telescope")
local actions = require("telescope.actions")

telescope.setup({
  defaults = {
    prompt_prefix = " S9 // ",
    selection_caret = "> ",
    entry_prefix = "  ",

    sorting_strategy = "ascending",

    layout_strategy = "horizontal",
    layout_config = {
      width = 0.90,
      height = 0.84,

      horizontal = {
        prompt_position = "top",
        preview_width = 0.55,
      },
    },

    border = true,
    borderchars = {
      prompt = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
      results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
      preview = { "─", "│", "─", "│", "┬", "┐", "┘", "┴" },
    },

    mappings = {
      i = {
        ["<Esc>"] = actions.close,
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
      },

      n = {
        ["q"] = actions.close,
        ["j"] = actions.move_selection_next,
        ["k"] = actions.move_selection_previous,
      },
    },
  },

  pickers = {
    find_files = {
      hidden = true,

      find_command = {
        "fd",
        "--type",
        "f",
        "--hidden",
        "--exclude",
        ".git",
      },
    },

    buffers = {
      sort_lastused = true,
      ignore_current_buffer = true,
    },
  },
})

local highlights = {
  TelescopeNormal = {
    fg = "#c8d9e2",
    bg = "#050b12",
  },

  TelescopeBorder = {
    fg = "#294452",
    bg = "#050b12",
  },

  TelescopePromptNormal = {
    fg = "#c8d9e2",
    bg = "#0b1822",
  },

  TelescopePromptBorder = {
    fg = "#5bdaeb",
    bg = "#0b1822",
  },

  TelescopePromptPrefix = {
    fg = "#5bdaeb",
    bg = "#0b1822",
    bold = true,
  },

  TelescopePromptTitle = {
    fg = "#050b12",
    bg = "#5bdaeb",
    bold = true,
  },

  TelescopeResultsTitle = {
    fg = "#5bdaeb",
    bg = "#050b12",
    bold = true,
  },

  TelescopePreviewTitle = {
    fg = "#050b12",
    bg = "#50e6aa",
    bold = true,
  },

  TelescopeSelection = {
    fg = "#f3fbff",
    bg = "#153743",
    bold = true,
  },

  TelescopeSelectionCaret = {
    fg = "#50e6aa",
    bg = "#153743",
    bold = true,
  },

  TelescopeMatching = {
    fg = "#f2b84b",
    bold = true,
  },
}

for group, options in pairs(highlights) do
  vim.api.nvim_set_hl(0, group, options)
end
