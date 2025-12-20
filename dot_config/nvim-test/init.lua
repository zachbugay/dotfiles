vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Remove arrow keys in normal mode.
vim.keymap.set("n", "<Up>", "<Nop>")
vim.keymap.set("n", "<Down>", "<Nop>")
vim.keymap.set("n", "<Left>", "<Nop>")
vim.keymap.set("n", "<Right>", "<Nop>")

vim.opt.swapfile = false
vim.opt.undofile = true

local home = vim.loop.os_homedir()
vim.opt.undodir = home .. "/.config/nvim-test/undo"
vim.opt.undolevels = 10000
vim.opt.undoreload = 10000

vim.g.have_nerd_font = true
vim.opt.number = true -- Show line numbers
vim.opt.relativenumber = true
vim.opt.showmatch = true
vim.opt.hlsearch = true
vim.opt.tabstop = 2 -- The width of a tab is set to 4
vim.opt.shiftwidth = 2 -- Indents will have a width of 4
vim.opt.softtabstop = 2 -- Sets the number of columns for a TAB
vim.opt.expandtab = true -- Convert tabs to spaces
vim.opt.smartindent = true -- Automatically indent new lines
vim.opt.ttyfast = true -- Speed up scrolling
vim.opt.wrap = false -- Disable linewrap
vim.opt.cursorline = true -- Highlight the current line
vim.opt.list = true -- Show White Space
vim.opt.syntax = "on"
vim.opt.autoindent = true -- Copy indent from current line when starting a new line.
vim.opt.cursorline = true
vim.opt.autowrite = true
vim.opt.listchars = {
  space = "·", -- Middle dot for spaces
  tab = "→ ", -- Arrow for tabs (must be at least 2 chars)
  trail = "•", -- Bullet for trailing spaces
  extends = "⟩", -- Character for text that extends beyond the screen
  precedes = "⟨", -- Character for text that precedes the screen
  nbsp = "␣", -- Non-breaking space
}

vim.opt.colorcolumn = "120"
vim.opt.ff = "unix"
local sysName = vim.loop.os_uname().sysname

if sysName == "Windows_NT" then
  vim.opt.shell = "pwsh.exe"
  vim.opt.shellcmdflag =
    "-NoLogo -NonInteractive -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;$PSStyle.Formatting.Error = '';$PSStyle.Formatting.ErrorAccent = '';$PSStyle.Formatting.Warning = '';$PSStyle.OutputRendering = 'PlainText';"
  vim.opt.shellredir = "2>&1 | Out-File -Encoding utf8 %s; exit $LastExitCode"
  vim.opt.shellpipe = "2>&1 | Out-File -Encoding utf8 %s; exit $LastExitCode"
  vim.opt.shellquote = ""
  vim.opt.shellxquote = ""
end

print("Loaded custom options.")
