-- ============================================================
-- SECTION 9 // SYNTAX ANALYSIS
-- ============================================================

require("nvim-treesitter").setup({
  install_dir = vim.fn.stdpath("data") .. "/site",
})

local group = vim.api.nvim_create_augroup(
  "Section9Treesitter",
  { clear = true }
)

-- These are Neovim filetypes, not parser package names.
local filetypes = {
  "c",
  "cpp",
  "lua",
  "python",
  "sh",

  "javascript",
  "javascriptreact",
  "typescript",
  "typescriptreact",

  "html",
  "css",

  "json",
  "jsonc",
  "yaml",
  "toml",

  "markdown",
  "vim",
  "query",
}

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = filetypes,

  callback = function(args)
    -- Enable Neovim's built-in Treesitter highlighting.
    local ok, error_message = pcall(
      vim.treesitter.start,
      args.buf
    )

    if not ok then
      vim.notify(
        "Treesitter could not start: " .. tostring(error_message),
        vim.log.levels.WARN
      )
      return
    end

    -- Treesitter folding, initially opened rather than collapsed.
    vim.wo.foldmethod = "expr"
    vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.wo.foldlevel = 99
    vim.o.foldlevelstart = 99
  end,
})

-- Connect Treesitter captures to the Section 9 base theme.
local capture_links = {
  ["@comment"] = "Comment",

  ["@string"] = "String",
  ["@string.escape"] = "Special",

  ["@number"] = "Number",
  ["@boolean"] = "Boolean",
  ["@constant"] = "Constant",

  ["@function"] = "Function",
  ["@function.call"] = "Function",
  ["@function.method"] = "Function",
  ["@function.method.call"] = "Function",

  ["@keyword"] = "Keyword",
  ["@keyword.function"] = "Keyword",
  ["@keyword.return"] = "Keyword",
  ["@keyword.conditional"] = "Keyword",
  ["@keyword.repeat"] = "Keyword",

  ["@type"] = "Type",
  ["@type.builtin"] = "Type",

  ["@variable"] = "Identifier",
  ["@variable.builtin"] = "Identifier",
  ["@property"] = "Identifier",

  ["@markup.heading"] = "Title",
  ["@markup.link"] = "Underlined",
}

for capture, target in pairs(capture_links) do
  vim.api.nvim_set_hl(0, capture, {
    link = target,
  })
end
