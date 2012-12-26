
-- Setup display
local xrandr = {
   naruto = "--output VGA1 --auto --output DVI1 --auto --left-of VGA1",
   neo    = "--output HDMI-0 --auto --output DVI-0 --auto --right-of HDMI-0",
   alucard = "--output DVI-0 --auto --output DVI-1 --auto --right-of DVI-0"
}
if xrandr[config.hostname] then
   os.execute("xrandr " .. xrandr[config.hostname])
end

-- Spawn a composoting manager
-- awful.util.spawn("xcompmgr -C -c -F -f", false)
--awful.util.spawn("xcompmgr -c -C -t-5 -l-5 -r4.2 -o.55", false)
--awful.util.spawn("xcompmgr -Ss -n -Cc -fF -I-10 -O-10 -D1 -t-3 -l-4 -r4 &", false)
--awful.util.spawn("xcompmgr", false)
awful.util.spawn("compton -cCG -o 0.75 -f 0.05﻿ -t 0.01 -l 0.01 -r 2.5 &", false)

-- Start idempotent commands
local execute = {
   -- Start PulseAudio
   "pulseaudio --check || pulseaudio -D",
   "xset -b",	-- Disable bell
   -- Enable numlock
   "numlockx on",
   -- Read resources
   "xrdb -merge " .. awful.util.getdir("config") .. "/Xresources",
   -- Default browser
   "xdg-mime default " .. config.browser .. ".desktop x-scheme-handler/http",
   "xdg-mime default " .. config.browser .. ".desktop x-scheme-handler/https",
   "xdg-mime default " .. config.browser .. ".desktop text/html"
}

-- Keyboard/Mouse configuration
-- Default config.hostname=neo
if config.hostname == "alucard" then
   execute = awful.util.table.join(
      execute, {
         -- Keyboard and mouse
         "xset m 4 3",	-- Mouse acceleration
         "setxkbmap us,fr '' compose:rwin ctrl:nocaps grp:rctrl_rshift_toggle",
         "xmodmap -e 'keysym Pause = XF86ScreenSaver'",
               })
elseif config.hostname == "neo" then
   execute = awful.util.table.join(
      execute, {
         -- Keyboard and mouse
         "xset m 3 3",	-- Mouse acceleration
         "setxkbmap us,fr '' compose:rwin ctrl:nocaps grp:rctrl_rshift_toggle",
         "xmodmap -e 'keysym Pause = XF86ScreenSaver'",
               })
elseif config.hostname == "guybrush" then
   execute = awful.util.table.join(
      execute, {
         -- Keyboard and mouse
         "setxkbmap us,fr '' compose:ralt ctrl:nocaps grp:rctrl_rshift_toggle",
--         "xmodmap -e 'keysym XF86AudioPlay = XF86ScreenSaver'",
         "xmodmap -e 'keysym XF86WebCam = XF86ScreenSaver'",
         -- Wheel emulation
         "xinput set-int-prop 'TPPS/2 IBM TrackPoint' 'Evdev Wheel Emulation' 8 1",
         "xinput set-int-prop 'TPPS/2 IBM TrackPoint' 'Evdev Wheel Emulation Button' 8 2",
         "xinput set-int-prop 'TPPS/2 IBM TrackPoint' 'Evdev Wheel Emulation Axes' 8 6 7 4 5",
         -- Disable touchpad
         "xinput set-int-prop 'SynPS/2 Synaptics TouchPad' 'Synaptics Off' 8 1"})
elseif config.hostname == "IdeaPad-Y470" then
   execute = awful.util.table.join(
      execute, {
         -- Keyboard and mouse
--	 "synclient touchpadoff=1"
--       "xset m 3 3",	-- Mouse acceleration
--       "setxkbmap us,fr '' compose:rwin ctrl:nocaps grp:rctrl_rshift_toggle",
--       "xmodmap -e 'keysym Pause = XF86ScreenSaver'",
--         "setxkbmap -option ctrl:nocaps"
               })
end
--   xrun("pidgin", "pidgin -n")

if config.hostname == "neo" then
   xrun("keepassx", "keepassx -min -lock")
   xrun("transmission", "transmission-gtk -m")
elseif config.hostname == "guybrush" then
   xrun("keepassx", "keepassx -min -lock")
   xrun("NetworkManager Applet", "nm-applet")
elseif config.hostname == "IdeaPad-Y470" then
   xrun("stardict","stardict")
   xrun( "Artha", "artha")
   xrun( "parcellite", "parcellite")
   xrun( "Keynav", "keynav")
   xrun( "Fcitx", "fcitx")
   xrun( "Dropbox", "dropbox")
   xrun( "fetchmail", "fetchmail -kv")
--   xrun( "emacs", "emacs --daemon")
--   xrun( "Osdlyrics", "osdlyrics")
--   xrun( "xbindkeys", "xbindkeys &")
--   xrun( "Emacs", "emacs")
end
