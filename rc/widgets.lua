-- Widgets
local vicious = require("vicious")
local icons = loadrc("icons", "vbe/icons")
local disk = loadrc("diskusage")
--require("mocp")
-- colors
local color_red = "#ff0000"
local color_white = "#ffffff"
local color_black = "#000000"
local color_green = "#00ff00"
local color_blue = "#0000ff"

---------------------------------------------------------------------------

--[[ mocp
mocpwidget = widget({ type = 'textbox', name = 'mocpwidget', align = 'right'})
mocp.setwidget(mocpwidget)
mocpwidget:buttons({
                      button({ }, 1, function () mocp.play(); mocp.popup() end ),
                      button({ }, 2, function () awful.util.spawn('mocp --toggle-pause') end),
                      button({ }, 4, function () awful.util.spawn('mocp --toggle-pause') end),
                      button({ }, 3, function () awful.util.spawn('mocp --previous'); mocp.popup() end),
                      button({ }, 5, function () awful.util.spawn('mocp --previous'); mocp.popup() end)
                   })
mocpwidget.mouse_enter = function() mocp.popup() end
awful.hooks.timer.register (mocp.settings.interval,mocp.scroller)
--]]


local tb_moc = widget({ type = "textbox"})
tb_moc:buttons(awful.util.table.join( awful.button({ }, 1, function() spotify("PlayPause") end),
--                                              awful.button({ }, 3, function() spotify("Stop") end),
                                              awful.button({ }, 4, function() spotify("Previous") end),
                                              awful.button({ }, 5, function() spotify("Next") end)))
function hook_moc()
   moc_info = io.popen("mocp -i"):read("*all")
       moc_state = string.gsub(string.match(moc_info, "State: %a*"),"State: ","")
       if moc_state == "PLAY" or moc_state == "PAUSE" then
           moc_artist = string.gsub(string.match(moc_info, "Artist: %C*"), "Artist: ","")
           moc_title = string.gsub(string.match(moc_info, "SongTitle: %C*"), "SongTitle: ","")
           moc_curtime = string.gsub(string.match(moc_info, "CurrentTime: %d*:%d*"), "CurrentTime: ","")
           moc_totaltime = string.gsub(string.match(moc_info, "TotalTime: %d*:%d*"), "TotalTime: ","")
           if moc_artist == "" then
               moc_artist = "unknown artist"
           end
           if moc_title == "" then
               moc_title = "unknown title"
           end
           moc_string = moc_title
           --moc_artist .. " - " .. moc_title .. "(" .. moc_curtime .. "/" .. moc_totaltime .. ")"
           if moc_state == "PAUSE" then
               moc_string = "-" .. moc_string .. "-"
           end
       else
           moc_string = "NULL"
       end
       tb_moc.text = moc_string
end
--awful.hooks.timer.register(1, function() hook_moc() end)

---------------------------------------------------------------------------

--Create a weather widget
weatherwidget = widget({ type = "textbox" })
--weatherwidget.text = "郑州：".. awful.util.pread("weather -i zhcc --headers=Temperature --quiet -m | awk '{print $2, $3}'")
weathertimer = timer({ timeout = 7200 })
weathertimer:add_signal("timeout", function()
                           weatherwidget.text = "郑州：".. awful.util.pread(
                              "weather -i zhcc --headers=Temperature --quiet -m | awk '{print $2, $3}' &")
                                   end)
--weathertimer:start() -- Start the timer
weatherwidget:add_signal("mouse::enter", function()
                            weather = naughty.notify(
                               {title="Weather", timeout = 60 ,text=awful.util.pread("weather -i zhcc -m")})
                                         end)
weatherwidget:add_signal("mouse::leave", function() naughty.destroy(weather) end)

-- Separators
local sepopen = widget({ type = "imagebox" })
sepopen.image = image(beautiful.icons .. "/widgets/left.png")
local sepclose = widget({ type = "imagebox" })
sepclose.image = image(beautiful.icons .. "/widgets/right.png")
local spacer = widget({ type = "imagebox" })
spacer.image = image(beautiful.icons .. "/widgets/spacer.png")


-- MocTitle
local moctitlewidget = widget({ type = "textbox"})
local function update_moctitle() --{{{ returns current cpu frequency
   if err ~= awful.util.pread("[[ -z $(pidof mocp) ]]", false) then
--      moctitlewidget.text = awful.util.pread(" mocp -Q '%song-%artist'",true)
      moctitlewidget.text = awful.util.pread(" mocp -Q '%song'",true)
   else
      moctitlewidget.text = ""
   end
end
awful.hooks.timer.register(3, function() update_moctitle() end)

moctitlewidget:buttons(awful.util.table.join( awful.button({ }, 1, function() spotify("PlayPause") end),
--                                              awful.button({ }, 3, function() spotify("Stop") end),
                                              awful.button({ }, 4, function() spotify("Previous") end),
                                              awful.button({ }, 5, function() spotify("Next") end)))

-- cpu_temperature
local tzswidget = widget({ type = "textbox" })
vicious.register(tzswidget, vicious.widgets.thermal,
        function (widget, args)
           if args[1] > 60 then
              tzfound = true
              return string.format('<span color="'.. color_red .. '">%2d</span>', args[1]) .. "°C "
           else if args[1] > 0 then
                 tzfound = true
                 return " " .. args[1] .. "°C "
                else return ""
                end
           end
        end
        , 19, "thermal_zone0")

-- Org Date
local orgtextclock = widget({ type = "textbox" })
local dateformat = "%a %d/%m %H:%M/%p" --%H:%M
if screen.count() > 1 then dateformat = "%a %d/%m, " .. dateformat end
vicious.register(orgtextclock, vicious.widgets.date,
                 '<span color="'.. color_green ..'">' .. dateformat .. '</span>', 61)
local orglendar = require('orglendar')
orglendar.files = {
-- Specify here all files you want to be parsed, separated by comma.
   "/home/nopcall/Documents/Notes/work.org",
--   "/home/nopcall/Documents/stuff/home.org"
}
orglendar.register(orgtextclock)

-- CPU usage
local cpuwidget = widget({ type = "textbox" })
vicious.register(cpuwidget, vicious.widgets.cpu,
                 function (widget, args)
                    if args[1] > 50 then
                       return string.format('<span color="'.. color_red .. '">%2d%% </span>', args[1])
                    else
                       return string.format('<span color="'.. color_white .. '">%2d%% </span>', args[1])
                    end
                 end, 7)
local cpuicon = widget({ type = "imagebox" })
cpuicon.image = image(beautiful.icons .. "/widgets/cpu.png")


---------------------------------------------------------------------------
-- CPU usage detail
cpuloadwidget_icon = widget({	type = 'imagebox' , align = 'right' })
cpuloadwidget_icon.image = image(beautiful.cpuloadwidget_icon)
cpuloadwidget_icon.resize = false
cpuloadwidget_icon.valign = 'center'
awful.widget.layout.margins[cpuloadwidget_icon] = { top = 5 }
cpuloadwidget = widget({ type = 'textbox' , align = 'right' })
cpuspeedwidget = widget({ type = 'textbox' , align = 'right' })
function update_cpuloadwidget()
  if cpu0_total == null then
    cpu0_total = 0
    cpu0_active = 0
  end
    local f = io.open('/proc/stat')
    for l in f:lines() do
     values = {}
     start = 1
     splitstart, splitend = string.find(l, ' ', start)
     while splitstart do
       m = string.sub(l, start, splitstart-1)
       if m:gsub(' ','') ~= '' then
         table.insert(values, m)
       end
       start = splitend+1
       splitstart, splitend = string.find(l, ' ', start)
     end
     m = string.sub(l, start)
     if m:gsub(' ','') ~= '' then
            table.insert(values, m)
     end
     cpu_usage = values
    if cpu_usage[1] == "cpu0" then
            total_new = cpu_usage[2]+cpu_usage[3]+cpu_usage[4]+cpu_usage[5]
            active_new = cpu_usage[2]+cpu_usage[3]+cpu_usage[4]
            diff_total = total_new-cpu0_total
            diff_active = active_new-cpu0_active
            usage_percent = math.floor(diff_active/diff_total*100)
            cpu0_total = total_new
            cpu0_active = active_new
            cpuloadwidget.text =  usage_percent .. "%/"
    end
    end
    f:close()
end
function update_cpuspeedwidget() --{{{ returns current cpu frequency
  local f = io.open("/proc/cpuinfo")
  local line = f:read()
  while line do
    if line:match("cpu MHz") then
      ghz = math.floor(((string.match(line, "%d+") / 1000) * 10^1) + 0.5) / (10^1)
    end
    line = f:read()
  end
  io.close(f)
  cpuspeedwidget.text =  ghz .. "Ghz/"
end --}}}
update_cpuspeedwidget()
update_cpuloadwidget()
awful.hooks.timer.register(1, function() update_cpuspeedwidget() end)
awful.hooks.timer.register(1, function() update_cpuloadwidget() end)
---------------------------------------------------------------------------

-- Memory usage
local memwidget = widget({ type = "textbox" })
vicious.register(memwidget, vicious.widgets.mem,
                 '<span color="' .. color_white .. '">$1%</span>', 19)
local memicon = widget({ type = "imagebox" })
memicon.image = image(beautiful.icons .. "/widgets/mem.png")

---------------------------------------------------------------------------
-- Memory usage detail
memoryusedwidget_icon = widget({	type = 'imagebox' , align = 'right' })
memoryusedwidget_icon.image = image(beautiful.memoryusedwidget_icon)
memoryusedwidget_icon.resize = false
memoryusedwidget_icon.valign = 'center'
awful.widget.layout.margins[memoryusedwidget_icon] = { top = 5 }
memoryusedwidget = widget({ type = 'textbox' , align = 'right' })
disk.addToWidget(memoryusedwidget, 75, 90, true)
function update_memoryusedwidget()
local mem_free, mem_total, mem_c, mem_b
  local mem_percent, swap_percent, line, f, count
  count = 0
  f = io.open("/proc/meminfo")
  line = f:read()
  while line and count < 4 do
    if line:match("MemFree:") then
      mem_free = string.match(line, "%d+")
      count = count + 1;
    elseif line:match("MemTotal:") then
      mem_total = string.match(line, "%d+")
      count = count + 1;
    elseif line:match("Cached:") then
      mem_c = string.match(line, "%d+")
      count = count + 1;
    elseif line:match("Buffers:") then
      mem_b = string.match(line, "%d+")
      count = count + 1;
    end
    line = f:read()
  end
  io.close(f)
--  memoryusedwidget.text =  math.floor(100 * (mem_total - mem_free - mem_b - mem_c ) / mem_total).. "%/" .. math.floor(mem_total / 1000) .. "M" ;
  memoryusedwidget.text =  math.floor(100 * (mem_total - mem_free - mem_b - mem_c ) / mem_total).. "%/" .. math.floor(mem_total / 1000000) .. "G" ;
end
update_memoryusedwidget()
awful.hooks.timer.register(1, function() update_memoryusedwidget() end)
---------------------------------------------------------------------------

-- Battery
local mybattmon = widget({ type = "textbox" })
--vicious.register(cpuwidget, vicious.widgets.cpu,
function battery_status ()
    local battery = 0
    local time = 0
    local state = 0  -- discharging = -1, charging = 1, nothing = 0
    local icon = ""
    local fd = io.popen("powersave -b", "r")
    if not fd then
        do return "no info" end

    end
    local text = fd:read("*a")
    io.close(fd)
    if string.match(text, "discharging") then
        state = -1
        icon =  "▾"
    else
        state = 1
        icon = "▴"
    end

    battery = string.match(text, "Remaining percent: (%d+)")
    time = string.match(text, "Remaining minutes: (%d+)")
    -- above string does not always match
    if not time then
        time = string.match(text, "(%d+) minutes until fully charged")
    end

    return battery .. "%/" .. time .. "m" .. "<b>" .. icon .."</b>"
end
function hook_timer ()
    mybattmon.text = " " .. battery_status() .. " "
end
---
local batwidget = { widget = "" }
if config.hostname == "IdeaPad-Y470" then
   batwidget.widget = widget({ type = "textbox" })
   vicious.register(batwidget.widget, vicious.widgets.bat,
                    function (widget, args)
                       local color = color_white
                       local current = args[2]
                       if current < 10 and args[1] == "-" then
                          color = color_red
                          -- Maybe we want to display a small warning?
                          if current ~= batwidget.lastwarn then
                             batwidget.lastid = naughty.notify(
                                { title = "Battery low!",
                                  preset = naughty.config.presets.critical,
                                  timeout = 20,
                                  text = "Battery level is currently " ..
                                     current .. "%.\n" .. args[3] ..
                                     " left before running out of power.",
                                  icon = icons.lookup({name = "battery-caution",
                                                       type = "status"}),
                                  replaces_id = batwidget.lastid }).id
                             batwidget.lastwarn = current
                          end
                       end
                       return string.format('<span color="' .. color ..
                             '">%s%d%%</span>', args[1], current)
                    end,
                    59, "BAT1")
end
local baticon = widget({ type = "imagebox" })
baticon.image = image(beautiful.icons .. "/widgets/bat.png")
-- Wifi-----------------------------------------------------------------------
--Utility Functions
function trim(s)
   return s:find'^%s*$' and '' or s:match'^%s*(.*%S)'
end
-- Define Widget
local mywirelessmon = widget({ type = "textbox" })
--Retrieve Status For Widget
function wireless_status ()
   local output = {} --output buffer
   local fd = io.popen("iwconfig wlan0", "r")
   local line = fd:read()
   local ssid = trim(string.match(line, "ESSID:(.+)"))

   if ssid and ssid ~= "off/any" then
--      table.insert(output,'<span color="' .. color_white .. '">'.. ssid ..'</span>')
      return '<span color="' .. color_white .. '">'.. ssid ..'</span>'
   else
--      table.insert(output,'<span color="' .. color_red .. '">Disconnected</span>')
      return '<span color="' .. color_red .. '">Disconnected</span>'
   end
   return ""
end
--Bind Timer, status function, and widget
mywirelessmon.text = wireless_status()
my_wireless_timer=timer({timeout=5})
my_wireless_timer:add_signal("timeout",
                             function()
                                mywirelessmon.text = wireless_status()
                             end)
my_wireless_timer:start()
------------------------------------------------------------------------------
-- Network
local netdown = widget({ type = "textbox" })
local netdownicon = widget({ type = "imagebox" })
netdownicon.image = image(beautiful.icons .. "/widgets/down.png")
local netup   = widget({ type = "textbox" })
local netupicon = widget({ type = "imagebox" })
netupicon.image = image(beautiful.icons .. "/widgets/up.png")

local netgraph = awful.widget.graph()
netgraph:set_width(80):set_height(16)
netgraph:set_stack(true):set_scale(true)
netgraph:set_border_color(color_black) -- use black to hide border
netgraph:set_stack_colors({ "#EF8171", "#cfefb3" })
netgraph:set_background_color("#00000033")
vicious.register(netup, vicious.widgets.net,
    function (widget, args)
       -- We sum up/down value for all interfaces
       local down = 0
       local up = 0
       local iface
       for name, value in pairs(args) do
          iface = name:match("^{(%S+) down_b}$")
          if iface and iface ~= "lo" then down = down + value end
          iface = name:match("^{(%S+) up_b}$")
          if iface and iface ~= "lo" then up = up + value end
       end
       -- Update the graph
       netgraph:add_value(down, 2)
       netgraph:add_value(up, 1)
       -- Format the string representation
       local format = function(val)
          if val > 500000 then
             return string.format("%.1f MB", val/1000000.)
          elseif val > 500 then
             return string.format("%.1f KB", val/1000.)
          end
          return string.format("%d B", val)
       end
       -- Down
       netdown.text = string.format('<span color="' .. color_white .. '">%s/</span>', format(down)) --08s
       -- Up
       return string.format('<span color="' .. color_white .. '">%s</span>', format(up))
    end, 3)

-- Volume level
local volwidget = widget({ type = "textbox" })
vicious.register(volwidget, vicious.widgets.volume,
                 '<span color="' .. color_white .. '">$2 $1%</span>',
                 17, "Master")
volume = loadrc("volume", "vbe/volume")
volwidget:buttons(awful.util.table.join(
                     awful.button({ }, 1, volume.mixer),
                     awful.button({ }, 3, volume.toggle),
                     awful.button({ }, 4, volume.increase),
                     awful.button({ }, 5, volume.decrease)))
local volicon = widget({ type = "imagebox" })
volicon.image = image(beautiful.icons .. "/widgets/vol.png")

-- File systems
local fs = { "/",
       "/home",
       "/var",
       "/usr",
       "/tmp",
       "/var/cache/build",
       "/var/lib/mongodb",
       "/var/lib/systems" }
local fsicon = widget({ type = "imagebox" })
fsicon.image = image(beautiful.icons .. "/widgets/disk.png")
local fswidget = widget({ type = "textbox" })
vicious.register(fswidget, vicious.widgets.fs,
                 function (widget, args)
                    local result = ""
                    for _, path in pairs(fs) do
                       local used = args["{" .. path .. " used_p}"]
                       local color = color_white
                       if used then
                          if used > 90 then
                             color = color_red
                          end
                          local name = string.gsub(path, "[%w/]*/(%w+)", "%1")
                          if name == "/" then name = "root" end
                          result = string.format(
                             '%s%s<span color="' .. color_green .. '">%s: </span>' ..
                                '<span color="' .. color .. '">%2d%%</span>',
                             result, #result > 0 and " " or "", name, used)
                       end
                    end
                    return result
                 end, 53)

local systray = widget({ type = "systray" })

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

        sepclose,
        on(1,orgtextclock),
        on(1,spacer),
        on(1, systray),
--        on(1,spacer),
--        on(1,weatherwidget),
        on(1,spacer),
        on(1, volwidget),
--        screen.count() > 1 and on(1, volicon) or "",
        on(1, volicon),
        on(1, spacer),
        on(1, batwidget.widget),
        on(1, batwidget.widget ~= "" and baticon or ""),
        on(1, batwidget.widget ~= "" and spacer or ""),
--This is file-system useage if you want to disable it you can remove "--"
--        on(2, fswidget), screen.count() > 1 and on(2, fsicon) or "",
--        screen.count() > 1 and on(2, sepopen) or on(2, spacer),
--        screen.count() > 1 and on(1, netgraph.widget) or "",
--      on(1, netgraph.widget),
--        on(1, netupicon),
        on(1, netup),
--        on(1, netdownicon),
        on(1, netdown),
        on(1, spacer),
        on(1, mywirelessmon),
        on(1,spacer),
--        on(1, memwidget),
        on(1,memoryusedwidget),
--        on(1,memoryusedwidget_icon),
        on(1, memicon),
        on(1, cpuwidget),
        on(1,cpuspeedwidget), on(1, cpuloadwidget),
--        on(1,cpuloadwidget_icon),
        on(1, cpuicon),
--        on(1,spacer),
        on(1, tzswidget),
        on(1, spacer),
--        on(1, err ~= awful.util.pread("[[ -z $(pidof mocp) ]]") and spacer or ""),
--        on(1,moctitlewidget),
        on(1,tb_moc),
        on(1, sepopen),


        tasklist[s],
        layout = awful.widget.layout.horizontal.rightleft,

    }
end

config.keys.global = awful.util.table.join(
   config.keys.global,
   awful.key({ modkey }, "r", function () promptbox[mouse.screen]:run() end,
             "Prompt for a command"))

config.taglist = taglist
