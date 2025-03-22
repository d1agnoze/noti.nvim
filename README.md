# Noti.nvim
A really ---REALLY--- simple notification plugins for neovim (around ~200 loc)  

> This plugin is in very early stage of development, so i gonna save u the time by just saying this is probably not what u looking for. But if you want to contribute, hit the PR!
![image](https://github.com/user-attachments/assets/4a92a502-0ab0-4d60-bc3f-25af39e95391)

## Features:
 - Replaces `vim.notify` API with floating window notification
 - Provides a simple notification center window to view past logs

## Install:

Install via your preferred package manager

### `lazy.nvim`

 ```lua
     { 
        "d1agnoze/noti.nvim",
        opts = {}
     }

 ```

### Usage
`noti.nvim` provides these commands:
 - `NotiToggle` toggle notification center
 - `NotiView` open notification center
 - `NotiClose` close notification center
 - `NotiClear` removes all logs

### Setup
 **default options:**
 ```lua
    {
        -- setting for push notification
        quick = { 
            width = 0.30, -- window width (in percentage)
            height = 0.1, -- window height (in percentage)
            position = "bottom-right", -- "bottom-right", "top-right", "center", "bottom-left", "top-left" (i didn't test these tho -__- )
            wait = 5000, -- wait time before the window closes if self
        },

        -- setting for notification center
        center = { 
            width = 0.30,
            height = 0.5,
            position = "bottom-right",
        },

        filter = { "INFO", "WARN", "ERROR" }, --- only show notification those these levels

        --- use original vim.notify API along with replaced one (just gonna put it here for future development)
        keep_original = false, 

        --- max number of log to save (this plugin saves the logs on memory so be careful)
        max_logs = 30, 
    }
```

**Future roadmap:**
- [x] Colored log level
- [ ] Update docs and help files 
- [ ] Use original `vim.notify` along with the replaced one
- [ ] More customization options
