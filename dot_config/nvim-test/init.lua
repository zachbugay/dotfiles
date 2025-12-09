vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Remove arrow keys in normal mode.
vim.keymap.set("n", "<Up>", "<Nop>")
vim.keymap.set("n", "<Down>", "<Nop>")
vim.keymap.set("n", "<Left>", "<Nop>")
vim.keymap.set("n", "<Right>", "<Nop>")

vim.o.swapfile = false
vim.o.undofile = true

local home = vim.loop.os_homedir()
vim.o.undodir = home .. "/.config/nvim-test/undo"
vim.o.undolevels = 10000
vim.o.undoreload = 10000

vim.g.have_nerd_font = true
vim.o.number = true -- Show line numbers
vim.o.relativenumber = true
vim.o.showmatch = true
vim.o.hlsearch = true
vim.o.tabstop = 2 -- The width of a tab is set to 4
vim.o.shiftwidth = 2 -- Indents will have a width of 4
vim.o.softtabstop = 2 -- Sets the number of columns for a TAB
vim.o.expandtab = true -- Convert tabs to spaces
vim.o.smartindent = true -- Automatically indent new lines
vim.o.ttyfast = true -- Speed up scrolling
vim.o.wrap = false -- Disable linewrap
vim.o.cursorline = true -- Highlight the current line
vim.o.list = true -- Show White Space
vim.o.syntax = "on"
vim.o.autoindent = true -- Copy indent from current line when starting a new line.
vim.o.cursorline = true
vim.o.autowrite = true
vim.opt.listchars = {
  space = "·", -- Middle dot for spaces
  tab = "→", -- Arrow for tabs (must be at least 2 chars)
  trail = "•", -- Bullet for trailing spaces
  extends = "⟩", -- Character for text that extends beyond the screen
  precedes = "⟨", -- Character for text that precedes the screen
  nbsp = "␣", -- Non-breaking space
}

vim.o.colorcolumn = "120"
vim.o.ff = "unix"
local sysName = vim.loop.os_uname().sysname

if sysName == "Windows_NT" then
  vim.o.shell = "pwsh.exe"
  vim.o.shellcmdflag =
    "-NoLogo -NonInteractive -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;$PSStyle.Formatting.Error = '';$PSStyle.Formatting.ErrorAccent = '';$PSStyle.Formatting.Warning = '';$PSStyle.OutputRendering = 'PlainText';"
  vim.o.shellredir = "2>&1 | Out-File -Encoding utf8 %s; exit $LastExitCode"
  vim.o.shellpipe = "2>&1 | Out-File -Encoding utf8 %s; exit $LastExitCode"
  vim.o.shellquote = ""
  vim.o.shellxquote = ""
end

-- vim.pack.add({
--   "https://github.com/nvim-treesitter/nvim-treesitter",
--   "https://github.com/mason-org/mason.nvim"
-- })
--
-- -- Setup mason?
-- require("mason").setup({
--     log_level = vim.log.levels.DEBUG,
--     ui = {
--         icons = {
--             package_installed = "✓",
--             package_pending = "➜",
--             package_uninstalled = "✗"
--         }
--     }
-- })
--
-- local registry = require("mason-registry")
-- local installs = { "clangd", "lua-language-server", "stylua" }
--
-- registry.refresh(function()
--     for i,v in ipairs(installs) do
--       if registry.is_installed(v) then
--         print("Yep " .. v .. " is installed!")
--       else
--         print("Nope " .. v .." is not installed!")
--       end
--     end
--   end
-- )
--
print("Loaded custom options.")
