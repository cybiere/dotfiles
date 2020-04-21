pcall(require, "luarocks.loader")

local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
local pulse = require("pulseaudio_dbus")
require("awful.hotkeys_popup.keys")

local address = pulse.get_address()
local connection = pulse.get_connection(address)
local core = pulse.get_core(connection)
local sink = pulse.get_device(connection, core:get_sinks()[1])

awful.util.spawn_with_shell(gears.filesystem.get_configuration_dir().."autostart.sh")

if awesome.startup_errors then
	naughty.notify({ preset = naughty.config.presets.critical,
	title = "Oops, there were errors during startup!",
	text = awesome.startup_errors })
end

do
	local in_error = false
	awesome.connect_signal("debug::error", function (err)
		-- Make sure we don't go into an endless error loop
		if in_error then return end
		in_error = true

		naughty.notify({ preset = naughty.config.presets.critical,
		title = "Oops, an error happened!",
		text = tostring(err) })
		in_error = false
	end)
end

beautiful.init(gears.filesystem.get_configuration_dir().."theme.lua")

terminal = "urxvt"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor
local browser      = "firefox"
local rofirun	   = "rofi -combi-modi drun,run -modi combi -dpi -show-icons -show combi"
local rofiwin	   = "rofi -dpi -show-icons -show window"
local rofissh	   = "rofi -dpi -show ssh"

modkey = "Mod4"
local altkey       = "Mod1"

awful.layout.layouts = {
	awful.layout.suit.tile,
	-- awful.layout.suit.tile.left,
	awful.layout.suit.tile.bottom,
	-- awful.layout.suit.tile.top,
	awful.layout.suit.fair,
	-- awful.layout.suit.fair.horizontal,
	-- awful.layout.suit.spiral,
	-- awful.layout.suit.spiral.dwindle,
	-- awful.layout.suit.max,
	-- awful.layout.suit.max.fullscreen,
	-- awful.layout.suit.magnifier,
	-- awful.layout.suit.corner.nw,
	-- awful.layout.suit.corner.ne,
	-- awful.layout.suit.corner.sw,
	-- awful.layout.suit.corner.se,
	awful.layout.suit.floating,
}
-- }}}

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock("%H:%M")

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
awful.button({ }, 1, function(t) t:view_only() end),
awful.button({ modkey }, 1, function(t)
	if client.focus then
		client.focus:move_to_tag(t)
	end
end),
awful.button({ }, 3, awful.tag.viewtoggle),
awful.button({ modkey }, 3, function(t)
	if client.focus then
		client.focus:toggle_tag(t)
	end
end),
awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local function set_wallpaper(s)
	-- Wallpaper
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		-- If wallpaper is a function, call it with the screen
		if type(wallpaper) == "function" then
			wallpaper = wallpaper(s)
		end
		gears.wallpaper.maximized(wallpaper, s, true)
	end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

local bat_warn = 100;

awful.screen.connect_for_each_screen(function(s)
	-- Wallpaper
	set_wallpaper(s)

	-- Each screen has its own tag table.
	awful.tag({ "  ", "  ", "  ", "  ", "  " }, s, awful.layout.layouts[1])

	-- Create a promptbox for each screen
	s.mypromptbox = awful.widget.prompt()
	-- Create an imagebox widget which will contain an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	s.mylayoutbox = awful.widget.layoutbox(s)
	s.mylayoutbox:buttons(gears.table.join(
	awful.button({ }, 1, function () awful.layout.inc( 1) end),
	awful.button({ }, 3, function () awful.layout.inc(-1) end),
	awful.button({ }, 4, function () awful.layout.inc( 1) end),
	awful.button({ }, 5, function () awful.layout.inc(-1) end)))
	-- Create a taglist widget
	s.mytaglist = awful.widget.taglist {
		screen  = s,
		filter  = awful.widget.taglist.filter.all,
		buttons = taglist_buttons
	}


	-- Create the wibox
	s.mywibox = awful.wibar({ position = "top", screen = s , height = beautiful.taskbar_height})



	local function rounded_bar(color)
		return wibox.widget {
			max_value     = 100,
			value         = 0,
			forced_width  = beautiful.bar_width,
			margins       = {
				top = beautiful.bar_margin,
				bottom = beautiful.bar_margin,
			},
			shape         = gears.shape.rounded_bar,
			border_width  = beautiful.bar_border,
			color         = color,
			background_color = beautiful.bar_bg,
			border_color  = beautiful.bar_bordercolor,
			widget        = wibox.widget.progressbar,
		}
	end

	local function dot_widget()
		return wibox.widget {
			{
				widget = wibox.widget.textbox(" "),
				forced_width = beautiful.bar_margin
			},
			shape              = gears.shape.circle,
			bg                 = beautiful.bar_bg,
			shape_border_color = beautiful.bar_bordercolor,
			shape_border_width = beautiful.bar_border,
			widget             = wibox.container.background,
			margins       = {
				top = beautiful.bar_margin,
				bottom = beautiful.bar_margin,
			},
		}
	end


	local volume_bar = rounded_bar(beautiful.bar_volume)
	local light_bar = rounded_bar(beautiful.bar_light)
	local bat_bar = rounded_bar(beautiful.bar_bat)
	local charging_dot = dot_widget()
	local network_dot = dot_widget()

	local function getIface()
		local f = io.open("/proc/net/route","r")
		for l in f:lines() do
			w = l:sub(1,string.find(l, "%s"))
			if w:sub(1,5) ~= "Iface" then break end
		end
		f:close()
		return w
	end

	function update_bars()
		--volume
		volume_bar.value = sink:get_volume_percent()[1]
		if sink:is_muted() then
			volume_bar.color = beautiful.bar_volume_mute
		else
			volume_bar.color = beautiful.bar_volume
		end

		--battery
		awful.spawn.easy_async_with_shell("acpi",function(out)
			if out:find("Charging") ~= nil then
				charging_dot.bg = beautiful.bar_bat
			else
				charging_dot.bg = beautiful.bar_bg
			end
			s=0
			i=0
			for p in string.gmatch(out,"(%d+)%%") do
				s = s+p
				i = i+1
			end
			perc = math.floor(s/i)
			if perc < 16 then
				if bat_warn > perc then
					naughty.notify({ 
					title = "Battery low",
					text = tostring(perc).."% remaining" })
					bat_warn = perc
				end	
			end	
			bat_bar.value = perc
		end)

		--light
		awful.spawn.easy_async_with_shell("xbacklight",function(out)
			light_bar.value = tonumber(out)
		end)

		--network
		local iface = getIface()
		if iface:sub(1,2) == "en" then
			network_dot.bg = beautiful.bar_ethernet
		elseif iface:sub(1,2) == "wl" then
			network_dot.bg = beautiful.bar_wifi
		else
			network_dot.bg = beautiful.bar_bg
		end
		fnet:close()
	end

	widgettimer = timer({ timeout = 5 })
	widgettimer:connect_signal("timeout",update_bars)
	widgettimer:start()


	s.mylayoutbox = awful.widget.layoutbox(s)
	s.mylayoutbox:buttons(gears.table.join(
	awful.button({ }, 1, function () awful.layout.inc( 1) end),
	awful.button({ }, 3, function () awful.layout.inc(-1) end),
	awful.button({ }, 4, function () awful.layout.inc( 1) end),
	awful.button({ }, 5, function () awful.layout.inc(-1) end)))

	s.systray = wibox.widget.systray()
	s.systray.visible = false

	-- Add widgets to the wibox
	rightbar = wibox.widget{
		layout = wibox.layout.fixed.horizontal,
		s.mypromptbox,
		s.systray,
		wibox.widget.textbox(" "),
		network_dot,
		wibox.widget.textbox(" "),
		light_bar,
		wibox.widget.textbox(" "),
		volume_bar,
		wibox.widget.textbox(" "),
		bat_bar,
		wibox.widget.textbox(" "),
		charging_dot,
		wibox.widget.textbox(" "),
	}

	s.mywibox:setup {
		layout = wibox.layout.align.horizontal,
		expand = "none",
		{
			layout = wibox.layout.fixed.horizontal,
			s.mytaglist,
			s.mylayoutbox,
		},
		mytextclock,
		rightbar
	}
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
awful.button({ }, 4, awful.tag.viewnext),
awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
{description="show help", group="awesome"}),
awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
{description = "view previous", group = "tag"}),
awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
{description = "view next", group = "tag"}),
awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
{description = "go back", group = "tag"}),

awful.key({ modkey }, "=", function ()
	awful.screen.focused().systray.visible = not awful.screen.focused().systray.visible
end, {description = "Toggle systray visibility", group = "custom"}
),

awful.key({ modkey,           }, "j",
function ()
	awful.client.focus.byidx( 1)
end,
{description = "focus next by index", group = "client"}
),
awful.key({ modkey,           }, "k",
function ()
	awful.client.focus.byidx(-1)
end,
{description = "focus previous by index", group = "client"}
),
awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
{description = "show main menu", group = "awesome"}),

-- Layout manipulation
awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
{description = "swap with next client by index", group = "client"}),
awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
{description = "swap with previous client by index", group = "client"}),
awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
{description = "focus the next screen", group = "screen"}),
awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
{description = "focus the previous screen", group = "screen"}),
awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
{description = "jump to urgent client", group = "client"}),
awful.key({ modkey,           }, "Tab",
function ()
	awful.client.focus.history.previous()
	if client.focus then
		client.focus:raise()
	end
end,
{description = "go back", group = "client"}),

-- Standard program
awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
{description = "open a terminal", group = "launcher"}),
awful.key({ modkey, "Control" }, "r", awesome.restart,
{description = "reload awesome", group = "awesome"}),
awful.key({ modkey, "Shift"   }, "q", awesome.quit,
{description = "quit awesome", group = "awesome"}),
awful.key({ }, "XF86MonBrightnessUp", function () awful.util.spawn("xbacklight -inc 5") end,
{description = "+10%", group = "hotkeys"}),
awful.key({ }, "XF86MonBrightnessDown", function () awful.util.spawn("xbacklight -dec 5") end,
{description = "-10%", group = "hotkeys"}),
awful.key({ modkey, altkey }, "l", function () awful.util.spawn("slock") end),
awful.key({}, "XF86AudioLowerVolume", function () sink:volume_down({5}) end),
awful.key({}, "XF86AudioRaiseVolume", function() sink:volume_up({5}) end),
awful.key({}, "XF86AudioMute", function () sink:toggle_muted() end),
awful.key({}, "XF86AudioMicMute", function () awful.util.spawn("amixer set Capture toggle") end),


awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
{description = "increase master width factor", group = "layout"}),
awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
{description = "decrease master width factor", group = "layout"}),
awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
{description = "increase the number of master clients", group = "layout"}),
awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
{description = "decrease the number of master clients", group = "layout"}),
awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
{description = "increase the number of columns", group = "layout"}),
awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
{description = "decrease the number of columns", group = "layout"}),
awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
{description = "select next", group = "layout"}),
awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
{description = "select previous", group = "layout"}),

awful.key({ modkey, "Control" }, "n",
function ()
	local c = awful.client.restore()
	-- Focus restored client
	if c then
		c:emit_signal(
		"request::activate", "key.unminimize", {raise = true}
		)
	end
end,
{description = "restore minimized", group = "client"}),

-- Prompt
awful.key({ modkey }, "r", function () awful.spawn(rofirun) end,
{description = "Run application", group = "launcher"}),
awful.key({ modkey }, "z", function () awful.spawn(rofissh) end,
{description = "Run SSH connection", group = "launcher"}),
awful.key({ modkey }, "e", function () awful.spawn(rofiwin) end,
{description = "Show windows", group = "launcher"}),
awful.key({ }, "Print", function () awful.spawn("flameshot gui") end,
{description = "screenshot", group = "launcher"}),


awful.key({ modkey }, "x",
function ()
	awful.prompt.run {
		prompt       = "Run Lua code: ",
		textbox      = awful.screen.focused().mypromptbox.widget,
		exe_callback = awful.util.eval,
		history_path = awful.util.get_cache_dir() .. "/history_eval"
	}
end,
{description = "lua execute prompt", group = "awesome"})
-- Menubar
-- awful.key({ modkey }, "p", function() menubar.show() end,
--          {description = "show the menubar", group = "launcher"})
)

clientkeys = gears.table.join(
awful.key({ modkey,           }, "f",
function (c)
	c.fullscreen = not c.fullscreen
	c:raise()
end,
{description = "toggle fullscreen", group = "client"}),
awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
{description = "close", group = "client"}),
awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
{description = "toggle floating", group = "client"}),
awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
{description = "move to master", group = "client"}),
awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
{description = "move to screen", group = "client"}),
awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
{description = "toggle keep on top", group = "client"}),
awful.key({ modkey,           }, "n",
function (c)
	-- The client currently has the input focus, so it cannot be
	-- minimized, since minimized clients can't have the focus.
	c.minimized = true
end ,
{description = "minimize", group = "client"}),
awful.key({ modkey,           }, "m",
function (c)
	c.maximized = not c.maximized
	c:raise()
end ,
{description = "(un)maximize", group = "client"}),
awful.key({ modkey, "Control" }, "m",
function (c)
	c.maximized_vertical = not c.maximized_vertical
	c:raise()
end ,
{description = "(un)maximize vertically", group = "client"}),
awful.key({ modkey, "Shift"   }, "m",
function (c)
	c.maximized_horizontal = not c.maximized_horizontal
	c:raise()
end ,
{description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
	globalkeys = gears.table.join(globalkeys,
	-- View tag only.
	awful.key({ modkey }, "#" .. i + 9,
	function ()
		local screen = awful.screen.focused()
		local tag = screen.tags[i]
		if tag then
			tag:view_only()
		end
	end,
	{description = "view tag #"..i, group = "tag"}),
	-- Toggle tag display.
	awful.key({ modkey, "Control" }, "#" .. i + 9,
	function ()
		local screen = awful.screen.focused()
		local tag = screen.tags[i]
		if tag then
			awful.tag.viewtoggle(tag)
		end
	end,
	{description = "toggle tag #" .. i, group = "tag"}),
	-- Move client to tag.
	awful.key({ modkey, "Shift" }, "#" .. i + 9,
	function ()
		if client.focus then
			local tag = client.focus.screen.tags[i]
			if tag then
				client.focus:move_to_tag(tag)
			end
		end
	end,
	{description = "move focused client to tag #"..i, group = "tag"}),
	-- Toggle tag on focused client.
	awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
	function ()
		if client.focus then
			local tag = client.focus.screen.tags[i]
			if tag then
				client.focus:toggle_tag(tag)
			end
		end
	end,
	{description = "toggle focused client on tag #" .. i, group = "tag"})
	)
end

clientbuttons = gears.table.join(
awful.button({ }, 1, function (c)
	c:emit_signal("request::activate", "mouse_click", {raise = true})
end),
awful.button({ modkey }, 1, function (c)
	c:emit_signal("request::activate", "mouse_click", {raise = true})
	awful.mouse.client.move(c)
end),
awful.button({ modkey }, 3, function (c)
	c:emit_signal("request::activate", "mouse_click", {raise = true})
	awful.mouse.client.resize(c)
end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
	-- All clients will match this rule.
	{ rule = { },
	properties = { border_width = beautiful.border_width,
	border_color = beautiful.border_normal,
	focus = awful.client.focus.filter,
	raise = true,
	keys = clientkeys,
	buttons = clientbuttons,
	screen = awful.screen.preferred,
	placement = awful.placement.no_overlap+awful.placement.no_offscreen,
	size_hints_honor = false
}
	},

	-- Floating clients.
	{ rule_any = {
		instance = {
			"DTA",  -- Firefox addon DownThemAll.
			"copyq",  -- Includes session name in class.
			"pinentry",
		},
		class = {
			"Arandr",
			"Blueman-manager",
			"Gpick",
			"Kruler",
			"MessageWin",  -- kalarm.
			"Sxiv",
			"Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
			"Wpa_gui",
			"veromix",
			"xtightvncviewer",
			"Maltego",
			"Vmrc"},

			-- Note that the name property shown in xprop might be set slightly after creation of the client
			-- and the name shown there might not match defined rules here.
			name = {
				"Event Tester",  -- xev.
			},
			role = {
				"AlarmWindow",  -- Thunderbird's calendar.
				"ConfigManager",  -- Thunderbird's about:config.
				"pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
			}
		}, properties = { floating = true }},

		-- Set Firefox to always map on the tag named "2" on screen 1.
		-- { rule = { class = "Firefox" },
		--   properties = { screen = 1, tag = "2" } },
	}
	-- }}}

	-- {{{ Signals
	-- Signal function to execute when a new client appears.
	client.connect_signal("manage", function (c)
		-- Set the windows at the slave,
		-- i.e. put it at the end of others instead of setting it master.
		-- if not awesome.startup then awful.client.setslave(c) end

		if awesome.startup
			and not c.size_hints.user_position
			and not c.size_hints.program_position then
			-- Prevent clients from being unreachable after screen count changes.
			awful.placement.no_offscreen(c)
		end
	end)

	-- Enable sloppy focus, so that focus follows mouse.
	client.connect_signal("mouse::enter", function(c)
		c:emit_signal("request::activate", "mouse_enter", {raise = false})
	end)

	client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
	client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
	-- }}}
