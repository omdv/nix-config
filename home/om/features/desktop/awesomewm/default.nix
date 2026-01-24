{ lib, config, ... }:
let
  colors = config.colorscheme.palette;
  kittyCmd = lib.getExe config.programs.kitty.package;
  rofiCmd = "${lib.getExe config.programs.rofi.package} -show drun";

  rcLua = ''
    local gears = require("gears")
    local awful = require("awful")
    require("awful.autofocus")
    local wibox = require("wibox")
    local beautiful = require("beautiful")
    local calendar_widget = require("awesome-wm-widgets.calendar-widget.calendar")

    beautiful.init({
        font          = "${config.fontProfiles.monospace.family} 11",
        bg_normal     = "#${colors.base00}",
        bg_focus      = "#${colors.base0D}",
        fg_normal     = "#${colors.base05}",
        fg_focus      = "#${colors.base00}",
        border_width  = 2,
        border_normal = "#${colors.base01}",
        border_focus  = "#${colors.base0D}",
        useless_gap   = 5,
    })

    awful.layout.layouts = {
        awful.layout.suit.tile.bottom,  -- horizontal split (master top)
        awful.layout.suit.tile,         -- vertical split (master left)
    }

    awful.screen.connect_for_each_screen(function(s)
        awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.suit.tile.bottom)

        s.mytaglist = awful.widget.taglist {
            screen = s,
            filter = awful.widget.taglist.filter.all,
        }

        local mybattery = awful.widget.watch(
            "cat /sys/class/power_supply/BAT1/capacity /sys/class/power_supply/BAT1/status", 30,
            function(widget, stdout)
                local capacity, status = stdout:match("(%d+)%s+(%a+)")
                local icon = status == "Charging" and "+" or status == "Discharging" and "-" or ""
                widget:set_text(" " .. icon .. capacity .. "% ")
            end)

        local myclock = wibox.widget.textclock(" %a %b %d, %H:%M ")
        local cw = calendar_widget({
            placement = 'top',
            radius = 8,
        })
        myclock:connect_signal("button::press",
            function(_, _, _, button)
                if button == 1 then cw.toggle() end
            end)

        s.mywibox = awful.wibar({ position = "top", screen = s, height = 24 })
        s.mywibox:setup {
            layout = wibox.layout.stack,
            {
                layout = wibox.layout.align.horizontal,
                { layout = wibox.layout.fixed.horizontal, s.mytaglist },
                nil,
                { layout = wibox.layout.fixed.horizontal, mybattery },
            },
            {
                widget = wibox.container.place,
                halign = "center",
                valign = "center",
                myclock,
            },
        }
    end)

    local modkey = "Mod4"

    local globalkeys = gears.table.join(
        awful.key({ modkey }, "Return", function() awful.spawn("${kittyCmd}") end),
        awful.key({ modkey }, "d", function() awful.spawn("${rofiCmd}") end),
        -- Focus
        awful.key({ modkey }, "Down", function() awful.client.focus.byidx(1) end),
        awful.key({ modkey }, "Up", function() awful.client.focus.byidx(-1) end),
        -- Swap windows
        awful.key({ modkey, "Shift" }, "Down", function() awful.client.swap.byidx(1) end),
        awful.key({ modkey, "Shift" }, "Up", function() awful.client.swap.byidx(-1) end),
        -- Move to master
        awful.key({ modkey, "Shift" }, "Left", function()
            local c = client.focus
            if c then c:swap(awful.client.getmaster()) end
        end),
        -- Resize
        awful.key({ modkey, "Control" }, "Left", function() awful.tag.incmwfact(-0.05) end),
        awful.key({ modkey, "Control" }, "Right", function() awful.tag.incmwfact(0.05) end),
        awful.key({ modkey, "Control" }, "Down", function() awful.client.incwfact(0.05) end),
        awful.key({ modkey, "Control" }, "Up", function() awful.client.incwfact(-0.05) end),
        -- Layout switch
        awful.key({ modkey }, "h", function() awful.layout.set(awful.layout.suit.tile.bottom) end),
        awful.key({ modkey }, "v", function() awful.layout.set(awful.layout.suit.tile) end),
        -- Awesome control
        awful.key({ modkey, "Control" }, "r", awesome.restart),
        awful.key({ modkey, "Shift" }, "e", awesome.quit)
    )

    for i = 1, 9 do
        globalkeys = gears.table.join(globalkeys,
            awful.key({ modkey }, "#" .. i + 9, function()
                local tag = awful.screen.focused().tags[i]
                if tag then tag:view_only() end
            end),
            awful.key({ modkey, "Shift" }, "#" .. i + 9, function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then client.focus:move_to_tag(tag) end
                end
            end)
        )
    end

    root.keys(globalkeys)

    local clientkeys = gears.table.join(
        awful.key({ modkey, "Shift" }, "q", function(c) c:kill() end)
    )

    local clientbuttons = gears.table.join(
        awful.button({ }, 1, function(c) c:emit_signal("request::activate", "mouse_click", {raise = true}) end),
        awful.button({ modkey }, 1, function(c)
            c:emit_signal("request::activate", "mouse_click", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ modkey }, 3, function(c)
            c:emit_signal("request::activate", "mouse_click", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    awful.rules.rules = {
        {
            rule = { },
            properties = {
                border_width = beautiful.border_width,
                border_color = beautiful.border_normal,
                focus = awful.client.focus.filter,
                raise = true,
                keys = clientkeys,
                buttons = clientbuttons,
                screen = awful.screen.preferred,
                placement = awful.placement.no_overlap + awful.placement.no_offscreen,
            }
        },
        {
            rule_any = { class = { "firefox", "Brave-browser" } },
            properties = { tag = "2" }
        },
        {
            rule_any = { class = { "Code", "Cursor", "dev.zed.Zed" } },
            properties = { tag = "3" }
        },
        {
            rule_any = { class = { "TelegramDesktop", "discord" } },
            properties = { tag = "5" }
        },
        {
            rule_any = { class = { "net-sourceforge-kolmafia-KoLmafia" } },
            properties = { tag = "6" }
        },
    }

    client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
    client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

    awful.spawn.with_shell("xsetroot -solid '#${colors.base00}'")
  '';
in
{
  imports = [ ../common/rofi.nix ];

  xdg.configFile."awesome/rc.lua".text = rcLua;
}
