config.keys = {}
config.mouse = {}
local volume = loadrc("volume", "vbe/volume")
local brightness = loadrc("brightness", "vbe/brightness")
local keydoc = loadrc("keydoc", "vbe/keydoc")

local function screenshot(client)
   if not client then
      client = "root"
   else
      client = client.window
   end
   local path = "/home/nopcall/Pictures/screenshots/" ..
      "screenshot-" .. os.date("%Y-%m-%d--%H-%M-%S") .. ".jpg"
--   awful.util.spawn("import -quality 95 -window " .. client .. " " .. path, false)
   awful.util.spawn_with_shell("scrot -s -q 1 -e" .. "'" .. "mv $f" .. " " .. path .. " '", 1)

--   local path = awful.util.getdir("config") .. "/screenshots/" ..
--      "screenshot-" .. os.date("%Y-%m-%d--%H:%M:%S") .. ".jpg"
--   awful.util.spawn("import -quality 95 -window " .. client .. " " .. path, false)
end

-- Function to toggle a given window to the currently selected and
-- focused tag. We need a filter. This function can be used to focus a
-- particular window. When the filter is unable to select something,
-- we undo previous actions (hence "toggle"). This function returns a
-- function that will effectively toggle things.
local function toggle_window(filter)
   local undo = {}		-- undo stack
   client.add_signal('unmanage',
                     function(c)
                        -- If the client is in the undo stack, remove it
                        while true do
                           idx = awful.util.table.hasitem(undo, c)
                           if not idx then break end
                           table.remove(undo, idx)
                        end
                     end)
   local toggle = function()
      -- "Current" screen
      local s = client.focus and client.focus.screen or mouse.screen
      local cl = filter()	-- Client to toggle
      if cl and client.focus ~= cl then
         -- So, we have a client.
         if not cl:isvisible() then
            -- But it is not visible. So we will add it to the current
            -- tag of the screen where it currently is
            local t = assert(awful.tag.selected(cl.screen))
            -- Add our tag to the client
            undo[#undo + 1] = { cl, t }
            awful.client.toggletag(t, cl)
         end

         -- Focus and raise the client
         if s ~= cl.screen then
            mouse.screen = cl.screen
         end
         client.focus = cl
         cl:raise()
      else
         -- OK, we need to restore the previously pushed window to its
         -- original state.
         local i = #undo
         while i > 0 do
            local cl, t = unpack(undo[i])
            -- We only handle visible clients that are attached to the
            -- appropriate tag. Otherwise, we try the next one.
            if cl and cl:isvisible() and t.selected and
               awful.util.table.hasitem(cl:tags(), t) then
               awful.client.toggletag(t, cl)
               table.remove(undo, i)
               return
            end
            i = i - 1
         end
         -- Clean up...
         while #undo > 10 do
            table.remove(undo, 1)
         end
      end
   end
   return toggle
end

-- Toggle pidgin conversation window
local toggle_pidgin = toggle_window(
   function ()
      return awful.client.cycle(function(c)
                            return awful.rules.match(c, { class = "Pidgin",
                                                          role = "conversation" })
                         end)()
   end)

-- Toggle urgent window
local toggle_urgent = toggle_window(awful.client.urgent.get)

-- Focus a relative screen (similar to `awful.screen.focus_relative`)
local function screen_focus(i)
    local s = awful.util.cycle(screen.count(), mouse.screen + i)
    local c = awful.client.focus.history.get(s, 0)
    mouse.screen = s
    if c then client.focus = c end
end

-- Send a command to spotify
function spotify(command)
--   awful.util.spawn("dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify " ..
--      "/org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player." .. command, false)
   if err ~= awful.util.pread("[[ -z $(pidof mocp) ]]", false) then
       if command == "PlayPause" then
         awful.util.spawn("mocp -G" , false)
         return
      end
      if command == "Next" then
         awful.util.spawn("mocp -f" , false)
         return
      end
      if command == "Previous" then
         awful.util.spawn("mocp -r" , false)
         return
      end
      if command == "Stop" then
         awful.util.spawn("mocp -s" , false)
         return
      end
   end
end

config.keys.global = awful.util.table.join(
   keydoc.group("Focus"),
   awful.key({ modkey,           }, "j",
             function ()
                awful.client.focus.byidx( 1)
                if client.focus then
                   client.focus:raise()
                end
             end,
             "Focus next window"),
   awful.key({ modkey,           }, "k",
             function ()
                awful.client.focus.byidx(-1)
                if client.focus then
                   client.focus:raise()
                end
             end,
             "Focus previous window"),
   awful.key({ modkey,           }, "Tab",
             function ()
                awful.client.focus.history.previous()
                if client.focus then
                   client.focus:raise()
                end
             end,
             "Focus previously focused window"),
   awful.key({ modkey,           }, "u", toggle_pidgin,
            "Toggle Pidgin conversation window"),
   awful.key({ modkey, "Control" }, "j", function ()
                screen_focus( 1)
                                         end,
             "Jump to next screen"),
   awful.key({ modkey, "Control" }, "k", function ()
                screen_focus(-1)
                                         end),
   keydoc.group("Layout manipulation"),

   awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end,
             "Increase master-width factor"),
   awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end,
             "Decrease master-width factor"),
   awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster( 1)      end,
             "Increase number of masters"),
   awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster(-1)      end,
             "Decrease number of masters"),
   awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol( 1)         end,
             "Increase number of columns"),
   awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol(-1)         end,
             "Decrease number of columns"),
   awful.key({ modkey,           }, "space", function () awful.layout.inc(config.layouts,  1) end,
             "Next layout"),
   awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(config.layouts, -1) end,
             "Previous layout"),
   awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
             "Swap with next window"),
   awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
             "Swap with previous window"),

   keydoc.group("Misc"),

-- {{{ sdcv/stardict
   awful.key({ modkey }, "d", function ()
                local f = io.popen("xsel -o")
                local new_word = f:read("*a")
                f:close()

                if frame ~= nil then
                   naughty.destroy(frame)
                   frame = nil
                   if old_word == new_word then
                      return
                   end
                end
                old_word = new_word

                local fc = ""
                local f  = io.popen("sdcv -n --utf8-output -u '牛津英汉双解美化版' "..new_word)
                for line in f:lines() do
                   fc = fc .. line .. '\n'
                end
                f:close()
                frame = naughty.notify({ text = fc, timeout = 20, width = 320 })
                              end),
   awful.key({ modkey, "Shift" }, "d", function ()
                awful.prompt.run({prompt = "Dict: "}, mypromptbox[mouse.screen].widget, function(cin_word)
                                    naughty.destroy(frame)
                                    if cin_word == "" then
                                       return
                                    end

                                    local fc = ""
                                    local f  = io.popen("sdcv -n --utf8-output -u '牛津英汉双解美化版' "..cin_word)
                                    for line in f:lines() do
                                       fc = fc .. line .. '\n'
                                    end
                                    f:close()
                                    frame = naughty.notify({ text = fc, timeout = 20, width = 320 })
                                                                                        end, nil, awful.util.getdir("cache").."/dict")
                                       end),
-- }}}

   -- Spawn a terminal
   awful.key({ modkey,           }, "Return", function () awful.util.spawn(config.terminal) end,
             "Spawn a terminal"),

   -- Screenshot
   awful.key({}, "Print", screenshot),

   -- Restart awesome
   awful.key({ modkey, "Control" }, "r", awesome.restart),

   -- Multimedia keys
   awful.key({ }, "XF86MonBrightnessUp",   brightness.increase),
   awful.key({ }, "XF86MonBrightnessDown", brightness.decrease),
   awful.key({ }, "XF86AudioRaiseVolume",  volume.increase),
   awful.key({ }, "XF86AudioLowerVolume",  volume.decrease),
   awful.key({ }, "XF86AudioMute",         volume.toggle),

   awful.key({ }, "XF86AudioPlay",        function() spotify("PlayPause") end),
   awful.key({ }, "XF86AudioPause",       function() spotify("PlayPause") end),
   awful.key({ }, "XF86AudioStop",        function() spotify("Stop") end),
   awful.key({ }, "XF86AudioNext",        function() spotify("Next") end),
   awful.key({ }, "XF86AudioPrev",        function() spotify("Previous") end),

   -- Help
   awful.key({ modkey, }, "F1", keydoc.display),
   -- Quit awesome
   awful.key({ modkey, "Shift", "Control"  }, "q", awesome.quit)
)

config.keys.client = awful.util.table.join(
   keydoc.group("Window-specific bindings"),
   awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end,
             "Fullscreen"),
   awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
             "Close"),
   awful.key({ modkey,           }, "o",
             function (c)
                local s = awful.util.cycle(screen.count(), c.screen + 1)
                if awful.tag.selected(s) then
                   c.screen = s
                   client.focus = c
                   c:raise()
                end
             end, "Move to the other screen"),
   awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle, "Toggle floating"),
   awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
             "Switch with master window"),
   awful.key({ modkey,           }, "t",      function (c) c:raise()            end,
             "Raise window"),
   awful.key({ modkey,           }, "s",      function (c) c.sticky = not c.sticky end,
             "Stick window"),
   awful.key({ modkey,           }, "i",      dbg,
             "Get client-related information"),
   awful.key({ modkey,           }, "m",
             function (c)
                c.maximized_horizontal = not c.maximized_horizontal
                c.maximized_vertical   = not c.maximized_vertical
                c:raise()
             end,
             "Maximize"),

   -- Screenshot
   awful.key({ modkey }, "Print", screenshot, "Screenshot")
)

keydoc.group("Misc")
config.mouse.client = awful.util.table.join(
   awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
   awful.button({ modkey }, 1, awful.mouse.client.move),
   awful.button({ modkey }, 3, awful.mouse.client.resize))
