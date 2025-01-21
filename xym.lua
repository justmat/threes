print("")
print("big honkin x/y macro pad for grid zero")
print("")

-- edit these to configure channel and cc numbers
local cc_chan = {4, 4, 4, 4}
local cc_num = {12, 13, 14, 15}
-- for drawing on the grid
local last_pressed = {1, 1}

local cc_val_x = 0
local cc_val_y = 0
local cc_val_negx = 0
local cc_val_negy = 0

draw_xy = function()
	grid_led_all(0)
	for i = 1, 16 do
		grid_led(last_pressed[1], i, 1)
		grid_led(i, last_pressed[2], 1)
	end
	grid_led(last_pressed[1], last_pressed[2], 10)
	grid_refresh()
end
draw_xy()


get_cc_vals = function()
	cc_val_x = math.floor(linlin(1, 16, 0, 127, last_pressed[1]))
	cc_val_y = math.floor(linlin(1, 16, 0, 127, last_pressed[2]))
	cc_val_negx = math.floor(linlin(1, 16, 127, 0, last_pressed[1]))
	cc_val_negy = math.floor(linlin(1, 16, 127, 0, last_pressed[2]))
end


grid = function(x, y, z)
	if z == 1 then
		last_pressed[1] = x
		last_pressed[2] = y
	end
	get_cc_vals()
	-- send ccs
	midi_cc(cc_num[1], cc_val_x, cc_chan[1])
	midi_cc(cc_num[2], cc_val_y, cc_chan[2])
	midi_cc(cc_num[3], cc_val_negx, cc_chan[3])
	midi_cc(cc_num[4], cc_val_negy, cc_chan[4])

	draw_xy()
end
