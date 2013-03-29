-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("vicious")
-- Notification library
require("naughty")

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init(awful.util.getdir("config") .. "/zenburn.lua")

-- Default modkey.
modkey = "Mod4"

-- Function aliases
local exec  = awful.util.spawn
local sexec = awful.util.spawn_with_shell

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.tile,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.fair,
    awful.layout.suit.max,
    awful.layout.suit.magnifier,
    awful.layout.suit.floating
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {
  names  = { "term", "web", "nagios", "im", "gobby", "emacs", 7 },
  layout = { layouts[4], layouts[4], layouts[1],
             layouts[1], layouts[6], layouts[1], layouts[6]
}}
for s = 1, screen.count() do
    tags[s] = awful.tag(tags.names, s, tags.layout)
    awful.tag.setncol(2, tags[s][4])
    awful.tag.setproperty(tags[s][4], "mwfact", 0.20)
    awful.tag.setproperty(tags[s][6], "mwfact", 0.44)
    awful.tag.setproperty(tags[s][7], "hide",   true)
end
-- }}}

-- {{{ Wibox

separator = widget({ type = "imagebox" })
separator.image = image(beautiful.widget_sep)

-- {{{ Date and time
dateicon = widget({ type = "imagebox" })
dateicon.image = image(beautiful.widget_date)
-- Initialize widget
datewidget = widget({ type = "textbox" })
-- Register widget
vicious.register(datewidget, vicious.widgets.date, "%a %b %d %R", 61)

require('calendar2')
calendar2.addCalendarToWidget(datewidget, "<span color='green'>%s</span>")
-- orglendar.files = { 
--    "/home/bakhti/.org/work.org",     "/home/bakhti/.org/ysacal.org",
--    "/home/bakhti/.org/personal.org", "/home/bakhti/.org/report.org" }
-- orglendar.register(datewidget)
-- Create a textclock widget
--mytextclock = awful.widget.textclock({ align = "right" })

-- Create a systray
mysystray = widget({ type = "systray" })

-- {{{ CPU usage and temperature
cpuicon = widget({ type = "imagebox" })
cpuicon.image = image(beautiful.widget_cpu)
-- Initialize widgets
cpugraph  = awful.widget.graph()
-- tzswidget = widget({ type = "textbox" })
-- Graph properties
cpugraph:set_width(50):set_height(20)
cpugraph:set_background_color(beautiful.fg_off_widget)
cpugraph:set_gradient_angle(0):set_gradient_colors({
   beautiful.fg_end_widget, beautiful.fg_center_widget, beautiful.fg_widget
}) -- Register widgets
vicious.register(cpugraph,  vicious.widgets.cpu,      "$1")
-- vicious.register(tzswidget, vicious.widgets.thermal, " $1C", 19, "thermal_zone0")
-- }}}

-- {{{ Memory usage
memicon = widget({ type = "imagebox" })
memicon.image = image(beautiful.widget_mem)
-- Initialize widget
membar = awful.widget.progressbar()
-- Pogressbar properties
membar:set_width(13):set_height(20):set_vertical(true)
membar:set_border_color(beautiful.border_widget)
membar:set_background_color(beautiful.fg_off_widget)
membar:set_gradient_colors({ beautiful.fg_widget,
   beautiful.fg_center_widget, beautiful.fg_end_widget
}) -- Register widget
vicious.register(membar, vicious.widgets.mem, "$1", 13)
-- }}}

-- {{{ Mail subject
mailicon = widget({ type = "imagebox" })
mailicon.image = image(beautiful.widget_mail)
-- Initialize widget
mailwidget = widget({ type = "textbox" })
-- Register widget
vicious.register(mailwidget, vicious.widgets.mdir, "$1", 181, {"/home/bakhti/Mail/critical/"})
-- Register buttons
-- mailwidget:buttons(awful.util.table.join(
--  awful.button({ }, 1, function () exec("urxvt -T Alpine -e alpine_exp") end)
-- ))
-- }}}

-- {{{ Org-mode agenda
orgicon = widget({ type = "imagebox" })
orgicon.image = image(beautiful.widget_org)
-- Initialize widget
orgwidget = widget({ type = "textbox" })
orgtask = widget({ type = "textbox", name = "orgtask" })
orgtask.text = '::<span color="'..beautiful.fg_urgent..'">Free</span>'
-- Configure widget
local orgmode = {
  files = {
    "/home/bakhti/.org/work.org",     "/home/bakhti/.org/ysacal.org",
    "/home/bakhti/.org/personal.org", "/home/bakhti/.org/report.org"
  },
  color = {
    past   = '<span color="'..beautiful.fg_urgent..'">',
    today  = '<span color="'..beautiful.fg_normal..'">',
    soon   = '<span color="'..beautiful.fg_widget..'">',
    future = '<span color="'..beautiful.fg_netup_widget..'">'
}} -- Register widget
vicious.register(orgwidget, vicious.widgets.org,
  orgmode.color.past..'$1</span>-'..orgmode.color.today .. '$2</span>-' ..
  orgmode.color.soon..'$3</span>-'..orgmode.color.future.. '$4</span>', 601,
  orgmode.files
) -- Register buttons
orgwidget:buttons(awful.util.table.join(
  awful.button({ }, 1, function () exec("/lhome/bakhti/.local/bin/emacsclient --eval '(org-agenda-list)'") end),
  awful.button({ }, 3, function () exec("/lhome/bakhti/.local/bin/emacsclient --eval '(make-remember-frame)'") end)
))
-- }}}

-- {{{ Volume level
volicon = widget({ type = "imagebox" })
volicon.image = image(beautiful.widget_vol)
-- Initialize widgets
volbar    = awful.widget.progressbar()
volwidget = widget({ type = "textbox" })
-- Progressbar properties
volbar:set_width(10)
volbar:set_height(20)
volbar:set_vertical(true)
volbar:set_background_color(beautiful.fg_off_widget)
volbar:set_border_color(beautiful.border_widget)
volbar:set_color(beautiful.fg_widget)
volbar:set_gradient_colors({ beautiful.fg_widget,
   beautiful.fg_center_widget, beautiful.fg_end_widget
})
-- Enable caching
-- vicious.enable_caching(vicious.widgets.volume)
-- Register widgets
vicious.register(volbar,    vicious.widgets.volume, "$1",  2, "PCM")
vicious.register(volwidget, vicious.widgets.volume, "$1%", 2, "PCM")
-- Register buttons
volbar.widget:buttons(awful.util.table.join(
   awful.button({ }, 1, function () exec("kmix") end),
   awful.button({ }, 2, function () exec("amixer -q sset Master toggle")   end),
   awful.button({ }, 4, function () exec("amixer -q sset PCM 2dB+", false) end),
   awful.button({ }, 5, function () exec("amixer -q sset PCM 2dB-", false) end)
)) -- Register assigned buttons
volwidget:buttons(volbar.widget:buttons())
-- }}}

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
--    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ screen = s,
        fg = beautiful.fg_normal, height = 20,
        bg = beautiful.bg_normal, position = "top",
        border_color = beautiful.border_normal,
        border_width = beautiful.border_width
    })

    -- Create a table with widgets that go to the right
    right_aligned = {
        layout = awful.widget.layout.horizontal.rightleft
    }
    table.insert(right_aligned, mylayoutbox[s])
    table.insert(right_aligned, separator)
    table.insert(right_aligned, datewidget)
    table.insert(right_aligned, dateicon)
    table.insert(right_aligned, separator)
    if s == 1 then table.insert(right_aligned, mysystray) end
    table.insert(right_aligned, separator)
    table.insert(right_aligned, volwidget)
    table.insert(right_aligned, volbar.widget)
    table.insert(right_aligned, volicon)
    table.insert(right_aligned, separator)
    table.insert(right_aligned, mailwidget)
    table.insert(right_aligned, mailicon)
    table.insert(right_aligned, separator)
    table.insert(right_aligned, orgtask)
    table.insert(right_aligned, orgwidget)
    table.insert(right_aligned, orgicon)
    table.insert(right_aligned, separator)
    table.insert(right_aligned, cpugraph.widget)
    table.insert(right_aligned, cpuicon)
    table.insert(right_aligned, separator)
    table.insert(right_aligned, membar.widget)
    table.insert(right_aligned, memicon)
    table.insert(right_aligned, separator)

    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        mytaglist[s],
        mypromptbox[s],
        right_aligned,
        layout = awful.widget.layout.horizontal.leftright,
        height = mywibox[s].height
    }
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey }, "e", function () exec("/lhome/bakhti/.local/bin/emacsclient -n -c") end),
--    awful.key({ modkey }, "q", function () exec("/lhome/bakhti/.local/bin/emacsclient --eval '(org-clock-select-task)'") end),
--    awful.key({ modkey }, "F11", function () exec("/lhome/bakhti/.local/bin/emacsclient --eval '(make-timetracker-frame)'") end),
    awful.key({ modkey }, "u", function () exec("firefox -app /lhome/bakhti/projects/conkeror/application.ini") end),
    awful.key({ modkey }, "g", function () sexec("gobby-0.5 -c sd:6524") end),
    awful.key({ modkey }, "v", function () exec("urxvt") end),
    awful.key({ modkey }, "m", function () exec("urxvt -e /bin/bash -i -c tmux") end),
    awful.key({ modkey }, "i", function () exec("/usr/bin/nagstamon /home/bakhti/.nagstamon/nagstamon-1") end),
    awful.key({ modkey }, "y", function () exec("/usr/bin/nagstamon /home/bakhti/.nagstamon/nagstamon-Y") end),
    awful.key({ modkey, "Control" }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey, "Control" }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
--    awful.key({ modkey,           }, "w", function () wwwmenu:toggle() end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.02)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.02)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey }, "f", function (c) awful.titlebar.remove(c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Control" }, "r", function (c) c:redraw() end),
    awful.key({ modkey, "Shift" }, "c", function (c) c:kill() end),
    awful.key({ modkey, "Shift" }, "0", function (c) c.sticky = not c.sticky end),
    awful.key({ modkey, "Shift" }, "m", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey, "Shift" }, "f", function (c) if awful.client.floating.get(c)
        then awful.client.floating.delete(c); awful.titlebar.remove(c)
        else awful.client.floating.set(c, true); awful.titlebar.add(c) end
    end),
    awful.key({ modkey, "Shift" }, "t", function (c)
        if c.titlebar then awful.titlebar.remove(c)
        else awful.titlebar.add(c, { modkey = modkey }) end
    end),
    awful.key({ modkey }, "o", awful.client.movetoscreen ),
--  awful.key({ modkey }, "n", function (c) c.minimized = not c.minimized end),
    awful.key({ modkey }, "Next",  function () awful.client.moveresize( 20,  20, -40, -40) end),
    awful.key({ modkey }, "Prior", function () awful.client.moveresize(-20, -20,  40,  40) end),
    awful.key({ modkey }, "Down",  function () awful.client.moveresize(  0,  20,   0,   0) end),
    awful.key({ modkey }, "Up",    function () awful.client.moveresize(  0, -20,   0,   0) end),
    awful.key({ modkey }, "Left",  function () awful.client.moveresize(-20,   0,   0,   0) end),
    awful.key({ modkey }, "Right", function () awful.client.moveresize( 20,   0,   0,   0) end),
    awful.key({ modkey, "Shift" }, "Right", function () awful.client.moveresize(-20,   0,   40,   0) end),
    awful.key({ modkey, "Shift" }, "Left",  function () awful.client.moveresize( 20,   0,  -40,   0) end),
    awful.key({ modkey }, "m", function (c)
        c.maximized_horizontal = not c.maximized_horizontal
        c.maximized_vertical   = not c.maximized_vertical
    end)
)

-- Compute the maximum number of digit we need, limited to 9
local keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true, size_hints_honor = false,
                     keys = clientkeys, buttons = clientbuttons } },
    { rule = { class = "Conkeror", instance = "Dialog" },
       properties = { sticky=true } },
    { rule = { class = "Conkeror", name = "Current Network Status.*" },
       properties = { tag = tags[screen.count()][3] } },
    { rule = { class = "Conkeror", instance = "Navigator" },
       properties = { tag = tags[screen.count()][2] } },
    { rule = { class = "Emacs", instance = "emacs" },
       properties = { tag = tags[screen.count()][6] } },
    { rule = { class = "Emacs", instance = "_FormFiller_" },
       properties = { floating = true } },
    { rule = { class = "Emacs", instance = "_Timetracker_" },
       properties = { floating = true } },
    { rule = { class = "Pidgin", role = "buddy_list" },
      properties = { tag = tags[screen.count()][4] } },
    { rule = { class = "Pidgin", role = "conversation"},
      properties = { tag = tags[1][4]}, callback = awful.client.setslave },
    { rule = { class = "Gobby", type = "Dialog" },
       properties = { sticky = true } },
    { rule = { class = "Gobby" },
       properties = { tag = tags[screen.count()][5] } },
    { rule = { instance = "nagstamon" },
       properties = { ontop = true, focusable = false } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add titlebar to floaters, but remove those from rule callback
    if awful.client.floating.get(c)
    or awful.layout.get(c.screen) == awful.layout.suit.floating then
        if   c.titlebar then awful.titlebar.remove(c)
        else awful.titlebar.add(c, {modkey = modkey}) end
    end

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus", function(c)
			      c.border_color = beautiful.border_focus
			      c.opacity = 1
			   end)
client.add_signal("unfocus", function(c)
				c.border_color = beautiful.border_normal
				c.opacity = 0.6
			     end)
-- }}}

-- {{{ Arrange signal handler
for s = 1, screen.count() do screen[s]:add_signal("arrange", function ()
    local clients = awful.client.visible(s)
    local layout = awful.layout.getname(awful.layout.get(s))

    for _, c in pairs(clients) do -- Floaters are always on top
        if   awful.client.floating.get(c) or layout == "floating"
        then if not c.fullscreen then c.above       =  true  end
        else                          c.above       =  false end
    end
  end)
end
-- }}}

require("autostart")
