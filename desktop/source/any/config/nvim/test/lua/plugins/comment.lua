return {
  {
    'numToStr/Comment.nvim',
    config = function ()
      require('Comment').setup()
    end,
    opts = {
        -- add any options here
    },
    lazy = false,
}
}
