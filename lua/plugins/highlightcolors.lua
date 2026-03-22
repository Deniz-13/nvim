return {
  'brenoprata10/nvim-highlight-colors',
  event = 'BufRead',
  config = function()
    require('nvim-highlight-colors').setup({})
  end
}
