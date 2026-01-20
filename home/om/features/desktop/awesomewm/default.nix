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

    awful.layout.layouts = { awful.layout.suit.tile }

    awful.screen.connect_for_each_screen(function(s)
        awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

        s.mytaglist = awful.widget.taglist {
            screen = s,
            filter = awful.widget.taglist.filter.all,
        }

        local mybattery = awful.widget.watch("cat /sys/class/power_supply/BAT1/capacity", 60, function(widget, stdout)
            widget:set_text(" " .. stdout:gsub("\n", "") .. "% ")
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
                wibox.widget.textclock(" %a %b %d, %H:%M "),
            },
        }
    end)

    local modkey = "Mod4"

    local globalkeys = gears.table.join(
        awful.key({ modkey }, "Return", function() awful.spawn("${kittyCmd}") end),
        awful.key({ modkey }, "d", function() awful.spawn("${rofiCmd}") end),
        awful.key({ modkey }, "j", function() awful.client.focus.byidx(1) end),
        awful.key({ modkey }, "k", function() awful.client.focus.byidx(-1) end),
        awful.key({ modkey }, "h", function() awful.tag.incmwfact(-0.05) end),
        awful.key({ modkey }, "l", function() awful.tag.incmwfact(0.05) end),
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
