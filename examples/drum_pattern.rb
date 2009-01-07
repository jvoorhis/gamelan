require 'rubygems'
require 'midiator'
require 'gamelan'

# Adjust Gamelan to automatically stop the background thread when no events are scheduled
module Gamelan
  class Queue
    def length
      @queue.length
    end
  end
  class Scheduler
    def run
      return if @running
      @running  = true
      @thread   = Thread.new do
        @phase  = 0.0
        @origin = @time = Time.now.to_f
        loop { dispatch; advance; break if @queue.length == 0 } # added break condition
      end
    end
  end
end

if not $MIDI
  $MIDI = MIDIator::Interface.new
  # $MIDI.autodetect_driver
  $MIDI.use(:dls_synth)
  at_exit { sleep 1; $MIDI.close } # sleep prevents the last note from getting cut off
end

# TR-808 drum kit
$MIDI.control_change 32, 10, 1 
$MIDI.program_change 10, 26

@scheduler = Gamelan::Scheduler.new({:tempo => 132})

def play(time_in_beats, pitch, velocity=80, channel=10)
  @scheduler.at(time_in_beats) { $MIDI.note_on(pitch, channel, velocity) }
  # play for 1/10 of a beat (doesn't really make a difference for drum sounds):
  @scheduler.at(time_in_beats + 0.1) { $MIDI.note_off(pitch, channel, velocity) }
end

kick1 = 32 
kick2 = 36
snare = 40

for beat_offset in 0..15
  play beat_offset, kick1 # every downbeat
  play beat_offset+0.5, kick2 # every upbeat
  if beat_offset % 4 == 0
    extra = (beat_offset % 8) / 4
    play beat_offset+extra, snare
  end
end

@scheduler.run.join
