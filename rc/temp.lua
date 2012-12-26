-- Wibox initialisation
local wibox     = {}
local promptbox = {}
local layoutbox = {}

local taglist = {}
local tasklist = {}
tasklist.buttons = awful.util.table.join(
   awful.button({ }, 1, function (c)
                   if c == client.focus then
                      c.minimized = true
                   else
                      if not c:isvisible() then
                         awful.tag.viewonly(c:tags()[1])
                      end
                      -- This will also un-minimize
                      -- the client, if needed
                      client.focus = c
                      c:raise()
                   end
                        end))

for s = 1, screen.count() do
    promptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    layoutbox[s] = awful.widget.layoutbox(s)
    tasklist[s]  = awful.widget.tasklist(
       function(c)
          local title, color, _, icon = awful.widget.tasklist.label.currenttags(c, s)
          return title, color, nil, icon
       end, tasklist.buttons)

    -- Create the taglist
    taglist[s] = awful.widget.taglist.new(s,
                                          awful.widget.taglist.label.all)
    -- Create the wibox
    wibox[s] = awful.wibox({ screen = s,
                             fg = beautiful.fg_normal,
                             bg = beautiful.bg_widget,
                             position = "top",
                             height = 16,
    })
    -- Add widgets to the wibox
    local on = function(n, what)
       if s == n or n > screen.count() then return what end
       return ""
    end

    wibox[s].widgets = {
        {
           screen.count() > 1 and sepopen or "",
           taglist[s],
           screen.count() > 1 and spacer or "",
           layoutbox[s],
           screen.count() > 1 and sepclose or "",
           promptbox[s],
           layout = awful.widget.layout.horizontal.leftright
        },
        on(1, systray),
        sepclose, datewidget, screen.count() > 1 and dateicon or "", spacer,
        on(1, volwidget), screen.count() > 1 and on(1, volicon) or "", on(2, spacer),
--	on(1, volwidget), on(1, volicon), on(1, spacer),
        on(1, musicwidget, on(1,spacer)), on(1, spacer),
--        on(1, batwidget.widget),
--        on(1, batwidget.widget ~= "" and baticon or ""),
--        on(1, batwidget.widget ~= "" and spacer or ""),
--This is file-system useage if you want to disable it you can remove "--"
--	on(2, fswidget), screen.count() > 1 and on(2, fsicon) or "",
--	screen.count() > 1 and on(2, sepopen) or on(2, spacer),
--
--        screen.count() > 1 and on(1, netgraph.widget) or "",
--        on(1, netupicon), on(1, netup),
--        on(1, netdownicon), on(1, netdown), on(1, spacer),
--	on(1, hddtempwidget, on(1,spacer)),     nowork
--        on(1, wifiwidget), on(1, wifiicon) , on(1,spacer),
--        on(1, memwidget), on(1, memicon), --on(1, spacer),
--        on(1, tzswidget),
--        on(1, cpuwidget), on(1, cpuicon), on(1, sepopen),
        tasklist[s],
        layout = awful.widget.layout.horizontal.rightleft }
end

config.keys.global = awful.util.table.join(
   config.keys.global,
   awful.key({ modkey }, "r", function () promptbox[mouse.screen]:run() end,
             "Prompt for a command"))

config.taglist = taglist
