-- require("myluamodule")

vim.opt.number          = true
vim.opt.showmatch       = true
vim.opt.hlsearch        = true
vim.opt.tabstop         = 4
vim.opt.softtabstop     = 4
vim.opt.expandtab       = true -- Convert tabs to spaces
vim.opt.smartindent     = true -- Automatically indent new lines
vim.opt.ttyfast         = true -- Speed up scrolling
vim.opt.wrap            = false -- Disable linewrap
vim.opt.cursorline      = true -- Highlight the current line
vim.opt.list            = true -- Show White Space
vim.opt.syntax          = "on"
vim.opt.autoindent      = true
vim.opt.cursorline      = true
vim.opt.autowrite       = true
vim.opt.listchars       = {
  space = "·",     -- Middle dot for spaces
  tab = "→ ",      -- Arrow for tabs (must be at least 2 chars)
  trail = "•",     -- Bullet for trailing spaces
  extends = "⟩",   -- Character for text that extends beyond the screen
  precedes = "⟨",  -- Character for text that precedes the screen
  nbsp = "␣"       -- Non-breaking space
}

vim.cmd('syntax enable')
vim.cmd('filetype plugin indent on')

