return { 
  { "catppuccin/nvim", name = "catppuccin"},
  { "neanias/everforest-nvim"},
  { "ellisonleao/gruvbox.nvim" },

  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
