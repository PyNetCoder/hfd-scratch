# hfd-scratch

Lightweight temporary scratch buffer plugin for Neovim with floating and horizontal layouts, filetype switching, and file saving support.

## Features

- **Flexible Layouts:** Open scratch buffers in a centered floating window or a bottom horizontal split.
- **Persistent Session Buffer:** Reuses the same hidden buffer across toggles without cluttering your workspace or creating swap files.
- **On-the-Fly Filetype Switching:** Quickly switch syntax highlighting and filetype (`lua`, `python`, `rust`, `go`, `markdown`, `text`, etc.).
- **Save Anytime:** Export scratch buffer contents directly to a real file via command or interactive prompt.

## Installation (lazy.nvim)

```lua
return {
  {
    "PyNetCoder/hfd-scratch",
    cmd = { "HfdScratch", "HfdScratchSave" },
    keys = {
      {
        "<leader>n",
        function()
          require("hfd.scratch").open()
        end,
        mode = "n",
        desc = "Toggle scratch buffer",
      },
    },
    opts = {
      layout = "float", -- "float" or "horizontal"
      height = 15,
      default_ft = "lua",
      keymap = false, -- Managed via lazy.nvim `keys` above
    },
    config = function(_, opts)
      require("hfd.scratch").setup(opts)
    end,
  },
}
```

## Commands

Command 
Description
:HfdScratch [ft]
Toggle the scratch buffer (optionally set or switch its filetype, e.g. :HfdScratch python).:HfdScratchSave [path]Save the current scratch buffer contents to a file (prompts for path if omitted).