#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

require 'rubygems'
require 'midiator'
require 'gamelan'

class DrumMachine
  def initialize
    @midi = MIDIator::Interface.new
    # @midi.autodetect_driver
    @midi.use(:dls_synth)
    
    # TR-808 drum kit
    @midi.control_change(32, 10, 1)
    @midi.program_change(10, 26)
    
    @scheduler = Gamelan::Scheduler.new({:tempo => 132})
    
    schedule_events
  end
  
  def play(time_in_beats, pitch, velocity=80, channel=10)
    @scheduler.at(time_in_beats) { @midi.note_on(pitch, channel, velocity) }
    # play for 1/10 of a beat (doesn't really make a difference for drum sounds):
    @scheduler.at(time_in_beats + 0.1) { @midi.note_off(pitch, channel, velocity) }
  end
  
  KICK1 = 32 
  KICK2 = 36
  SNARE = 40

  def schedule_events
    (0..15).each do |beat_offset|
      play(beat_offset, KICK1) # every downbeat
      play(beat_offset+0.5, KICK2) # every upbeat
      if beat_offset % 4 == 0
        extra = (beat_offset % 8) / 4
        play beat_offset+extra, SNARE
      end
    end
    
    @scheduler.at(16) { @scheduler.stop } # schedule shutdown
  end
  
  def run
    @scheduler.run
    @scheduler.join
    @midi.close
  end
end

DrumMachine.new.run
