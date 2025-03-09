# Noti.nvim
A really ---REALLY--- simple notification plugins for neovim (around ~200 loc)  

## Features:
 - Replaces `vim.notify` API with floating window notification
 - Provides a simple notification center window to view past logs

## Install:

### `lazy.nvim`

 ```lua
     { 
        "d1agnoze/noti.nvim",
        opts = {}
     }

 ```

 ***default options:***
 ```lua
    {
        quick = { -- setting for push notification
            width = 0.30, -- window width (in percentage)
            height = 0.1, -- window height (in percentage)
            position = "bottom-right", -- "bottom-right", "top-right", "center", "bottom-left", "top-left" (i didn't test these tho -__- )
            wait = 5000, -- wait time before the window closes if self
        },
        center = { -- setting for notification center
            width = 0.30,
            height = 0.5,
            position = "bottom-right",
        },
        filter = { "INFO", "WARN", "ERROR" }, --- only show notification those these levels
        keep_original = false, --- use original vim.notify API along with replaced one (just gonna put it here for future development)
        max_logs = 30, --- max number of log to save (this plugin saves the logs on memory so be careful)
    }
```

***Future roadmap:***
- [ ] Colored log level
- [ ] use original `vim.notify` along with the replaced one
- [ ] more customization options
