print("")
print("16n but on a grid zero")
print("edit the cc_numbers & cc_chans tables to configure")

-- change these numbers to configure your faders cc numbers
local cc_nums = {7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7}
-- change these numbers to configure midi channels for your faders
local cc_chans = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16}

grid_led_all(0)

local last_press = {}
for i = 1, 16 do
	last_press[i] = 16
	grid_led(i, last_press[i], 10)
end
grid_refresh()

function fader_fill(fader, val)
	for i = val, 16 do
		grid_led(fader, i, 1)
	end
end


grid = function(x, y, z)
	grid_led_all(0)
	local cc_val = math.floor(linlin(1, 16, 127, 0, y))
	if z == 1 then
		midi_cc(cc_nums[x], cc_val, cc_chans[x])
		last_press[x] = y
	end
	for i = 1, 16 do
		fader_fill(i, last_press[i])
		grid_led(i, last_press[i], 10)
	end
	grid_refresh()
end
