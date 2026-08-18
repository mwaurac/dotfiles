local g = vim.g
local opt = vim.opt

g.mapleader = " "
g.maplocalleader = "\\"

g.autoformat = true

opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.ruler = false
opt.confirm = true
opt.wrap = false      --disable line wrap
opt.tabstop = 2       -- number of spaces on tabs
opt.splitbelow = true --put new windows below current
opt.splitright = true --put new windows right of current
opt.shiftwidth = 4
opt.expandtab = true
