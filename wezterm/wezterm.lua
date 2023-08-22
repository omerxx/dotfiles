local wezterm = require 'wezterm'
return {
	-- color_scheme = 'termnial.sexy',
	color_scheme = 'Catppuccin Mocha',
	enable_tab_bar = false,
	font_size = 16.0,
	macos_window_background_blur = 19,
	-- window_background_image = '/Users/omerhamerman/Downloads/texture2.jpeg',
	-- window_background_image_hsb = {
	-- 	brightness = 0.05,
	-- 	hue = 1.0,
	-- 	saturation = 0.5,
	-- },
	-- window_background_opacity = 0.88,
	window_background_opacity = 1.0,
	-- window_decorations = 'NONE',
	keys = {
		{
			key = 'f',
			mods = 'CTRL',
			action = wezterm.action.ToggleFullScreen,
		},
	},
}
