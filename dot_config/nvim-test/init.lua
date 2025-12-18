vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Remove arrow keys in normal mode.
vim.keymap.set('n', '<Up>', '<Nop>');
vim.keymap.set('n', '<Down>', '<Nop>');
vim.keymap.set('n', '<Left>', '<Nop>');
vim.keymap.set('n', '<Right>', '<Nop>');

vim.opt.swapfile = false 
vim.opt.undofile = true
local home = vim.loop.os_homedir()
vim.opt.undodir = home .. "/.config/nvim-test/undo"
vim.opt.undolevels=10000
vim.opt.undoreload=10000

-- Show line numbers
vim.opt.number = true
-- Use 4 spaces instead of tab ()
-- Copy indent from current line when starting a new line.
vim.opt.autoindent = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
