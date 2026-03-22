-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

vim.opt.number = true
vim.opt.cursorline = true
vim.opt.relativenumber = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.smartindent = true
vim.opt.expandtab = true
vim.opt.autoindent = true

-- dont show mode as its already shown in the statusbar
vim.opt.showmode = false

-- mouse support
vim.opt.mouse = 'a'

-- sync clipboard
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- undo file
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

-- case insensitive search unless \C
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- preview substitutions live
vim.opt.inccommand = 'split'

-- confirm if there are unsaved changes
vim.opt.confirm = true


-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})
