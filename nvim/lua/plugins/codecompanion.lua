if false then
  return {}
end

return {
  {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "hrsh7th/nvim-cmp", -- Optional: For using slash commands and variables in the chat buffer
    "nvim-telescope/telescope.nvim", -- Optional: For using slash commands
    { "stevearc/dressing.nvim", opts = {} }, -- Optional: Improves the default Neovim UI
  },
  opts = {
    strategies = {
      chat = {
        adapter = "openai",
      }
    },
  },
  config = function()
      require("codecompanion").setup({
        adapters = {
          openai = function()
            return require("codecompanion.adapters").extend("openai", {
              env = {
                api_key = "cmd:pass APIs/OpenAIAPIKey",
              },
              schema = {
                model = {
                  default = "gpt-4.1-mini",
                },
              },
            })
          end,
        }
      })
    end
  }
}
