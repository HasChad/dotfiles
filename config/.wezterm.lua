local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Settings
config.enable_tab_bar = false
config.initial_cols = 100
config.initial_rows = 25
config.window_background_opacity = 0.9
config.window_padding = {
    left = 5,
    right = 5,
    top = 0,
    bottom = 0,
}

config.font = wezterm.font('Iosevka Extended', { weight = 'Medium'})
config.font_size = 11

config.scrollback_lines = 3000
config.color_scheme = 'Abernathy'
config.colors = {
    background = 'black',
    cursor_bg = 'white',
    cursor_fg = 'black',
    cursor_border = 'white',

}

-- Finish
return config
