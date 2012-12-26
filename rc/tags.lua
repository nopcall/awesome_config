-- Tags

local shifty = loadrc("shifty", "vbe/shifty")
local keydoc = loadrc("keydoc", "vbe/keydoc")

local tagicon = function(icon)
   if screen.count() < 2 then
      return beautiful.icons .. "/taglist/" .. icon .. ".png"
--   elseif screen.count() < 2 then
--      return awful.util.getdir("config") .. "/themes/night/icons/" .. icon .. ".png"
   end
   return nil
end

shifty.config.tags = {
--   { "☠", "⌥", "✇", "⌤", "⍜", "✣", "⌨", "⌘", "☕","☭", "⌥", "✇", "⌤", "☼", "⌘","♨", "⌨", "⚡", "✉", "☕", "❁", "☃", "☄", "⚢"}
   Web = {
      position = 9,
      mwfact = 0.7,
      exclusive = true,
      max_clients = 1,
      screen = math.max(screen.count(), 2),
      spawn = config.browser,    -- autorun config.browser
      icon = tagicon("firefox"),
      nopopup = true,           -- don't give focus on creation
   },
   Editor  = {
      position = 2,
      mwfact = 0.6,
      exclusive = true,
      screen = 1,
      spawn = "quickemacs",           -- autorun emacs
      icon = tagicon("emacs"),
      nopopup = true,           -- don't give focus on creation
   },
   Xterm = {
      position = 1,
      layout = awful.layout.suit.fair,
      exclusive = true,
      slave = true,
      spawn = "urxvt -e tmux attach",   -- autorun config.terminal
      icon = tagicon("awesome16"),
   },
   Gimp  = {
      position = 4,
      mwfact = 0.6,
      exclusive = true,
      screen = 1,
      icon = tagicon("gimp"),
      spawn = "gimp",           --auto run
      nopopup = true,           -- don't give focus on creation
   },
   Other = {
      position = 3,
      mwfact = 0.2,
      exclusive = true,
      --screen = math.max(screen.count(), 2),
      icon = tagicon("thunderbird"),
      nopopup = true,           -- don't give focus on creation
   }
}

-- Also, see rules.lua
shifty.config.apps = {
   {
      match = { role = { "conversation", "buddy_list"},
                class = { "Artha", "banshee", "Stardict",} }, --all will display on tag "⚢Other"
      tag = "Other",
   },
   {
      match = { role = { "browser" } },
      tag = "Web",
   },
   {
      match = { "emacs" },
      tag = "Editor",
   },
   {
      match = {  "URxvt","Terminator", "Conky", "Stardict" },
      startup = {
      tag = "Xterm"
      },
      intrusive = true,         -- Display even on exclusive tags
   },
   {
      match = { "Gimp" },
      tag = "Gimp"
   },
   {
      match = { class = { "Keepassx" , "Key[-]mon" },
                role = { "pop[-]up" },
                name = {"Firebug"},
                instance = { "plugin[-]container", "exe" } },
      intrusive = true,
   },
}

shifty.config.defaults = {
   layout = config.layouts[1],
   mwfact = 0.6,
   ncol = 1,
   sweep_delay = 1,
}

shifty.taglist = config.taglist -- Set in widget.lua
shifty.init()

config.keys.global = awful.util.table.join(
   config.keys.global,
   keydoc.group("Tag management"),
   awful.key({ modkey }, "Escape", awful.tag.history.restore, "Switch to previous tag"),
   awful.key({ modkey }, "p", awful.tag.viewprev, "View previous tag"),
   awful.key({ modkey }, "n", awful.tag.viewnext, "View next tag"),
   awful.key({ modkey, "Shift"}, "o",
             function()
                local t = awful.tag.selected()
                local s = awful.util.cycle(screen.count(), t.screen + 1)
                awful.tag.history.restore()
                t = shifty.tagtoscr(s, t)
                awful.tag.viewonly(t)
             end,
             "Send tag to next screen"),
   awful.key({ modkey }, 0, shifty.add, "Create a new tag"),
   awful.key({ modkey, "Shift" }, 0, shifty.del, "Delete tag"),
   awful.key({ modkey, "Control" }, 0, shifty.rename, "Rename tag"))

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, (shifty.config.maxtags or 9) do
   config.keys.global = awful.util.table.join(
      config.keys.global,
      keydoc.group("Tag management"),
      awful.key({ modkey }, i,
                function ()
                   local t = shifty.getpos(i)
                   local s = t.screen
                   local c = awful.client.focus.history.get(s, 0)
                   awful.tag.viewonly(t)
--                   mouse.screen = s                   --切换tag时自动把鼠标移动到左上角
                   if c then client.focus = c end
                end,
                i == 5 and "Display only this tag" or nil),
      awful.key({ modkey, "Control" }, i,
                function ()
                   local t = shifty.getpos(i)
                   t.selected = not t.selected
                end,
                i == 5 and "Toggle display of this tag" or nil),
      awful.key({ modkey, "Shift" }, i,
                function ()
                   local c = client.focus
                   if c then
                      local t = shifty.getpos(i)
                      awful.client.movetotag(t, c)
                   end
                end,
                i == 5 and "Move window to this tag" or nil),
      awful.key({ modkey, "Control", "Shift" }, i,
                function ()
                   if client.focus then
                      awful.client.toggletag(shifty.getpos(i))
                   end
                end,
                i == 5 and "Toggle this tag on this window" or nil),
      keydoc.group("Misc"))
end
