local wezterm = require("wezterm")
local platform = wezterm.target_triple

local default = {
    color_scheme = "Catppuccin Mocha",
}

local shells = {
    windows = { "pwsh.exe", "-NoLogo" },
    linux   = { "/usr/bin/fish", "-l" },
    darwin  = { "/opt/homebrew/bin/fish", "-l" },
}

for key, cmd in pairs(shells) do
    if platform:find(key) then
        default.default_prog = cmd
        return default
    end
end

default.default_prog = { wezterm.shell(), "-l" }
return default