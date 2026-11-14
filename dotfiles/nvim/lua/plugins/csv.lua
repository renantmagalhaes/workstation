-- Colored CSV & TSV (Rainbow CSV)
return {
  {
    "mechatroner/rainbow_csv",
    ft = { "csv", "tsv", "csv_semicolon", "csv_whitespace", "csv_pipe", "rfc_csv", "rfc_semicolon" },
    init = function()
      -- Automatically detect and highlight CSV separators
      vim.g.disable_rainbow_hover = 0
    end,
  },
}
