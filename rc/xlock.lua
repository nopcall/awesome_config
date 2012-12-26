-- Lockscreen

local icons = loadrc("icons", "vbe/icons")

xrun("xautolock",
     awful.util.getdir("config") ..
        "/bin/xautolock " ..
        icons.lookup({name = "system-lock-screen", type = "actions" }))
-- xrun("Xscreensaver","xscreensaver")

config.keys.global = awful.util.table.join(
   config.keys.global,
   awful.key({ modkey, "Control", "Shift" }, "l", function() awful.util.spawn("i3lock -i /home/nopcall/Pictures/background/screenlock.png", false) end))--XF86ScreenSaver "xautolock -locknow"

-- Configure DPMS
os.execute("xset dpms 1200 1800 3600")
