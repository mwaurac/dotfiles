hl.config({
	input = {
		kb_layout = "us",
		kb_variant = "",
		touchpad = {
			natural_scroll = true,
			tap_to_click = true,
		},
	},

	general = {
		gaps_in = 2,
		gaps_out = 0,
		border_size = 1,
		col = {
			active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
			inactive_border = "rgba(595959aa)",
		},
		layout = "dwindle",
	},

	decoration = {
		rounding = 4,
		blur = {
			enabled = true,
			passes = 1,
			new_optimizations = true,
		},
		shadow = {
			enabled = true,
		},
	},

	animations = {
		enabled = false,
	},

	dwindle = {
		force_split = 1,
		preserve_split = true,
	},
})

hl.curve("snappy", {
    type = "bezier",
    points = { {0.25, 1}, {0.5, 1} }
})

hl.animation({ leaf = "windows", enabled = true, speed = 3, bezier = "snappy", style = "slide" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "snappy", style = "slide" })
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "snappy" })
