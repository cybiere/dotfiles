---------------------------------------------
-- Awesome theme which follows xrdb config --
--   by Yauhen Kirylau                    --
---------------------------------------------

local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local xrdb = xresources.get_current_theme()
local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()

-- inherit default theme
-- local theme = dofile(themes_path.."default/theme.lua")
local theme = {}

theme.taskbar_height = dpi(26)

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- taglist_[bg|fg]_[focus|urgent|occupied|empty|volatile]
-- tasklist_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- prompt_[fg|bg|fg_cursor|bg_cursor|font]
-- hotkeys_[bg|fg|border_width|border_color|shape|opacity|modifiers_fg|label_bg|label_fg|group_margin|font|description_font]
-- Example:
--theme.taglist_bg_focus = "#ff0000"

-- Variables set for theming notifications:
-- notification_font
-- notification_[bg|fg]
-- notification_[width|height|margin]
-- notification_[border_color|border_width|shape|opacity]

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = "#cc0000"

theme.wallpaper = os.getenv("HOME").."/.wp.jpg"
custom_icon_dir = gfs.get_configuration_dir().."icons/"

-- You can use your own layout icons like this:
theme.layout_fairv = custom_icon_dir.."lay_fair.png"
theme.layout_floating  = custom_icon_dir.."lay_float.png"
theme.layout_tilebottom = custom_icon_dir.."lay_tilebot.png"
theme.layout_tile = custom_icon_dir.."lay_tile.png"

theme.taglist_squares_unsel_empty = custom_icon_dir.."tag_empty.png"
theme.taglist_squares_sel_empty = custom_icon_dir.."tag_sel.png"
theme.taglist_squares_unsel = custom_icon_dir.."tag_unsel.png"
theme.taglist_squares_sel = custom_icon_dir.."tag_sel.png"

-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = "breeze-dark"

-- load vector assets' generators for this theme

theme.font          = "DejaVu Sans 12"

theme.bg_normal     = xrdb.background
theme.bg_focus      = xrdb.color12
theme.bg_urgent     = xrdb.color9
theme.bg_minimize   = xrdb.color8
theme.bg_systray    = theme.bg_normal

theme.fg_normal     = xrdb.foreground
theme.fg_focus      = theme.bg_normal
theme.fg_urgent     = theme.bg_normal
theme.fg_minimize   = theme.bg_normal

theme.useless_gap   = dpi(3)
theme.border_width  = dpi(1)
theme.border_normal = xrdb.color0
theme.border_focus  = theme.bg_focus
theme.border_marked = xrdb.color10

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- taglist_[bg|fg]_[focus|urgent|occupied|empty|volatile]
theme.taglist_bg_focus = theme.bg_normal
theme.tasklist_bg_focus = theme.bg_normal
theme.tasklist_fg_focus = theme.fg_normal
-- tasklist_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- Example:
--theme.taglist_bg_focus = "#ff0000"

theme.tooltip_fg = theme.fg_normal
theme.tooltip_bg = theme.bg_normal

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = "#cc0000"


theme.bar_margin = dpi(9)
theme.bar_width = dpi(60)
theme.bar_border = dpi(0)
theme.bar_bordercolor = "#eceff4"
theme.bar_bg = "#272734"
theme.bar_volume = "#a3be8c"
theme.bar_volume_mute = "#434c5e"
theme.bar_bat = "#d08770"
theme.bar_light = "#ebcb8b"
theme.bar_wifi = "#b48ead"
theme.bar_ethernet = "#5e81ac"

return theme
