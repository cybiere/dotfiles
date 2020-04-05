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

theme.wallpaper = "/home/ncnd/.wp.jpg"
custom_icon_dir = "/home/ncnd/.config/awesome/icons/"

-- You can use your own layout icons like this:

theme.taglist_squares_unsel_empty = custom_icon_dir.."tag_empty.png"
theme.taglist_squares_sel_empty = custom_icon_dir.."tag_sel.png"
theme.taglist_squares_unsel = custom_icon_dir.."tag_unsel.png"
theme.taglist_squares_sel = custom_icon_dir.."tag_sel.png"


theme.layout_fairh = themes_path.."default/layouts/fairhw.png"
theme.layout_fairv = themes_path.."default/layouts/fairvw.png"
theme.layout_floating  = themes_path.."default/layouts/floatingw.png"
theme.layout_magnifier = themes_path.."default/layouts/magnifierw.png"
theme.layout_max = themes_path.."default/layouts/maxw.png"
theme.layout_fullscreen = themes_path.."default/layouts/fullscreenw.png"
theme.layout_tilebottom = themes_path.."default/layouts/tilebottomw.png"
theme.layout_tileleft   = themes_path.."default/layouts/tileleftw.png"
theme.layout_tile = themes_path.."default/layouts/tilew.png"
theme.layout_tiletop = themes_path.."default/layouts/tiletopw.png"
theme.layout_spiral  = themes_path.."default/layouts/spiralw.png"
theme.layout_dwindle = themes_path.."default/layouts/dwindlew.png"
theme.layout_cornernw = themes_path.."default/layouts/cornernww.png"
theme.layout_cornerne = themes_path.."default/layouts/cornernew.png"
theme.layout_cornersw = themes_path.."default/layouts/cornersww.png"
theme.layout_cornerse = themes_path.."default/layouts/cornersew.png"

-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = "breeze-dark"

icon_dir = "/usr/share/icons/"..theme.icon_theme.."/status/24/"

theme.icon_bat = {
	icon_dir.."battery-000.svg",
	icon_dir.."battery-010.svg",
	icon_dir.."battery-020.svg",
	icon_dir.."battery-030.svg",
	icon_dir.."battery-040.svg",
	icon_dir.."battery-050.svg",
	icon_dir.."battery-060.svg",
	icon_dir.."battery-070.svg",
	icon_dir.."battery-080.svg",
	icon_dir.."battery-090.svg",
	icon_dir.."battery-100.svg"
}
theme.icon_bat_charging = {
	icon_dir.."battery-000-charging.svg",
	icon_dir.."battery-010-charging.svg",
	icon_dir.."battery-020-charging.svg",
	icon_dir.."battery-030-charging.svg",
	icon_dir.."battery-040-charging.svg",
	icon_dir.."battery-050-charging.svg",
	icon_dir.."battery-060-charging.svg",
	icon_dir.."battery-070-charging.svg",
	icon_dir.."battery-080-charging.svg",
	icon_dir.."battery-090-charging.svg",
	icon_dir.."battery-100-charging.svg"
}
theme.icon_bat_charged = icon_dir.."battery-100-charging.svg"
theme.icon_vol_mute = icon_dir.."audio-volume-muted.svg"
theme.icon_vol_low = icon_dir.."audio-volume-low.svg"
theme.icon_vol_med = icon_dir.."audio-volume-medium.svg"
theme.icon_vol_high = icon_dir.."audio-volume-high.svg"
theme.icon_light = icon_dir.."redshift-status-on.svg"

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



-- Recolor Layout icons:
theme = theme_assets.recolor_layout(theme, theme.fg_normal)

return theme

