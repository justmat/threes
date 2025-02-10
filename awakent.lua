print("")
print("awake like sequencer")
print("")

midi_chan = 1
note = 0
root_note = 0
octave = 6
octaves = {0, 12, 24, 36, 48, 60, 72, 84, 96, 108}
last_note = nil
seq_1_pos = 1
seq_2_pos = 1
seq_1_len = 8
seq_2_len = 6
config_mode = false
playing = false

-- scales ----------
scale_names = {
  "major",
  "minor",
  "harm_minor",
  "mel_minor",
  "dorian",
  "phrygian",
  "lidian",
  "mixolidian",
  "locrian",
  "whole_tone",
  "six_tone",
  "double_harmonic"
}

scale_index = 1
scale = scale_names[scale_index]

scales = {}
-- scales are 2 octaves/14 notes
scales.major = {0, 2, 4, 5, 7, 9, 11, 12, 14, 16, 17, 19, 21, 23}
scales.minor = {0, 2, 3, 5, 7, 8, 10, 12, 14, 15, 17, 19, 20, 22}
scales.harm_minor = {0, 2, 3, 5, 7, 8, 11, 12, 14, 15, 17, 19, 20, 23}
scales.mel_minor = {0, 2, 3, 5, 7, 9, 11, 12, 14, 15, 17, 19, 21, 23}
scales.dorian = {0, 2, 3, 5, 7, 9, 10, 12, 14, 15, 17, 19, 21, 22}
scales.phrygian = {0, 1, 3, 5, 7, 8, 10, 12, 13, 15, 17, 19, 20, 22}
scales.lidian = {0, 2, 4, 6, 7, 9, 11, 12, 14, 16, 18, 19, 21, 23}
scales.mixolidian = {0, 2, 4, 5, 7, 9, 10, 12, 14, 16, 17, 19, 21, 22}
scales.locrian = {0, 1, 3, 5, 6, 8, 10, 12, 13, 15, 17, 18, 20, 22}
scales.whole_tone = {0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26}
scales.six_tone = {0, 1, 4, 5, 8, 9, 11, 12, 13, 16, 17, 20, 21, 23}
scales.double_harmonic = {0, 1, 4, 5, 7, 8, 11, 12, 13, 16, 17, 19, 20, 23}

-- set up default sequence tables
seq_1 = {1,0,3,5,6,7,5,7,0,0,0,0,0,0,0,0}
seq_2 = {5,7,0,0,0,0,0,0,0,0,0,0,0,0,0,0}


reset_seqs = function()
  seq_1_pos = 1
  seq_2_pos = 1
end

-- for grid visuals ----------
piano_y_selector = {2, 1, 2, 1, 2, 2, 1, 2, 1, 2, 1, 2}
scale_viz = {}


make_scale_viz = function(s)
  -- s = scale
  -- reset scale viz
  scale_viz = {}
  -- build new scale viz
  for i = 1, 7 do
    scale_viz[s[i] + 1] = 1
  end
end


step = function()
  if playing then
  	if last_note then midi_note_off(last_note, 0, midi_chan) end

  	if seq_1_pos > seq_1_len then seq_1_pos = 1 end
  	if seq_2_pos > seq_2_len then seq_2_pos = 1 end

    if seq_1[seq_1_pos] > 0 then
      note = scales[scale][seq_1_pos] + seq_2[seq_2_pos] + octaves[octave]
      midi_note_on(note + root_note, 64, midi_chan)
      last_note = note + root_note
    end

  	grid_draw()
    
    seq_1_pos = seq_1_pos + 1
    seq_2_pos = seq_2_pos + 1
  else
    -- reset sequencer posisions and stop metro
    metro_stop(1)
    reset_seqs()
  end
end


grid = function(x, y, z)
  if z == 1 then
    if config_mode then
      -- set root note and octave
      if x > 2 and x < 15 and y <= 2 then
        root_note = x - 3
      elseif y == 4 and x > 2 and x <= 14 then
        octave = x - 3 
      end
      -- scale select
      if x > 2 and x <= 14 and y == 12 then
        scale_index = x - 2
        scale = scale_names[scale_index]
        make_scale_viz(scales[scale])
      end
      -- return to the sequencers
      if x == 16 and y == 16 then
        config_mode = false
      end
    else
      -- add and remove notes from the sequences
      if y < 8 then
        if seq_1[x] == y then
          seq_1[x] = 0
        else
          seq_1[x] = y
        end
      elseif y > 8 and y < 16 then
        if seq_2[x] == y - 8 then
          seq_2[x] = 0
        else
          seq_2[x] = y - 8
        end
      end
      -- toggle transport or set sequence 1 length
      if y == 8 and x == seq_1_len then
        playing = not playing
        if playing then metro_set(1, 150) end
      elseif y == 8 then
        seq_1_len = x
      end
      -- enter config mode or set sequence 2 length
      if y == 16 and x == seq_2_len then
        config_mode = true
      elseif y == 16 then
        seq_2_len = x
      end
    end
  end
  grid_draw()
end


grid_draw = function()
	grid_led_all(0)

  if config_mode then
    -- config page
    -- root note selection
    for i = 3, 14 do
      grid_led(i, piano_y_selector[i - 2], root_note == (i - 3) and 10 or 4)
    end
    -- octave controls
    for i = 1, 10 do
      grid_led(i + 3, 4, i == octave and 10 or 4)
    end
    -- scale viz
    for i = 3, 14 do
      grid_led(i, piano_y_selector[i - 2] + 8, scale_viz[i - 2] == 1 and 10 or 4)
      grid_led(i, 12, (i - 2) == scale_index and 10 or 4)
    end
    -- button to leave config mode
    grid_led(16, 16, 4)
  else
    -- main sequencer page
    -- draw playheads
    for i = 1, 7 do
      grid_led(seq_1_pos, i, 4)
    end

    for i = 9, 15 do
      grid_led(seq_2_pos, i, 4)
    end
    -- draw sequences
    for i = 1, seq_1_len do
      if seq_1[i] > 0 then
		    grid_led(i, seq_1[i], 10)
      end
    end

    for i = 1, seq_2_len do
      if seq_2[i] > 0 then
		    grid_led(i, seq_2[i] + 8, 10)
      end
    end
    -- draw sequence lengths
    for i = 1, seq_1_len do
      grid_led(i, 8, 2)
      grid_led(seq_1_pos, 8, 4)
    end

    for i = 1, seq_2_len do
      grid_led(i, 16, 2)
      grid_led(seq_2_pos, 16, 4)
    end
  end
	grid_refresh()
end


metro = function(index, count)
	step()
end

--metro_set(1, 150)
make_scale_viz(scales[scale])
grid_draw()