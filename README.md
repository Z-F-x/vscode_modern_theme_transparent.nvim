# Please see [gmr458] (https://github.com/gmr458/vscode_modern_theme.nvim) for original fork!

# VSCode Modern theme for Neovim, Transparent
![screenshot-01](./screenshots/Screenshot_20241004_104859.png)

## Files / fzf
![screenshot-02](./screenshots/Screenshot_20241004_105126.png)

## Neo-Tree Filesystem and Editor
![screenshot-03](./screenshots/Screenshot_20241004_105151.png)


# Installation

[lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
  {
    "Z-F-x/vscode_modern_theme_transparent.nvim",
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
    lazy = false,
    priority = 1000,
    config = function()
      require("vscode_modern").setup({
        cursorline = true,
        transparent_background = true,
        nvim_tree_darker = true,
      })
      vim.cmd([[colorscheme vscode_modern]])

      vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
      vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
      vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })
    end,
  },

```
