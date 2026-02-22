local wezterm = require("wezterm")
local platform = wezterm.target_triple

local config = {
	color_scheme = "Catppuccin Mocha",
}

if platform:find("linux") then
	config.default_prog = { "/usr/bin/fish", "-l" }
	config.enable_kitty_graphics = true
	config.enable_wayland = true
end

if platform:find("windows") then
	config.default_prog = { "pwsh.exe", "-NoLogo" }
	config.animation_fps = 120
end

return config
