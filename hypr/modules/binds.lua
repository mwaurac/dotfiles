-- ╭─────────────────────────────────────────────╮
-- │  hypr binds.lua — Catppuccin Mocha          │
-- │  Modular keybindings configuration          │
-- ╰─────────────────────────────────────────────╯

local mainMod = "SUPER"

-- --- Application & Core Binds ---
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("ghostty"))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("rofi -show drun"))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd("hyprlock"))

-- --- Window Navigation (Vim-style) ---
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

-- --- Window Moving (Vim-style) ---
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))

-- --- Workspace Switching & Window Moving ---
for i = 1, 10 do
	local key = i % 10
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- --- Multimedia & Hardware Controls ---
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"), { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { repeating = true })

-- --- Screenshot Keybindings (grim + slurp) ---
-- Print: Interactive region screenshot (saved to ~/Pictures/Screenshots + clipboard)
hl.bind("Print", hl.dsp.exec_cmd('mkdir -p ~/Pictures/Screenshots && filepath=~/Pictures/Screenshots/Screenshot_$(date +%Y%m%d_%H%M%S).png && grim -g "$(slurp)" "$filepath" && wl-copy < "$filepath"'))

-- --- Laptop Lid Switch Binds ---
hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd("hyprlock && systemctl suspend"), { locked = true })

-- --- Logout / Session Controller Submap ---
hl.bind(mainMod .. " + escape", hl.dsp.submap("logout"))

hl.define_submap("logout", function()
	-- L: Lock screen
	hl.bind("l", function()
		hl.dispatch(hl.dsp.exec_cmd("hyprlock"))
		hl.dispatch(hl.dsp.submap("reset"))
	end)

	-- E: Exit / Logout
	hl.bind("e", hl.dsp.exit())

	-- S: Suspend
	hl.bind("s", function()
		hl.dispatch(hl.dsp.exec_cmd("systemctl suspend"))
		hl.dispatch(hl.dsp.submap("reset"))
	end)

	-- R: Reboot
	hl.bind("r", hl.dsp.exec_cmd("systemctl reboot"))

	-- P: Poweroff
	hl.bind("p", hl.dsp.exec_cmd("systemctl poweroff"))

	-- Escape or Catchall to cancel/reset submap
	hl.bind("escape", hl.dsp.submap("reset"))
	hl.bind("catchall", hl.dsp.submap("reset"))
end)
