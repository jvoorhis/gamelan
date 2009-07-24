module Gamelan
  DEFAULT_PRIORITY = 0
  
  # MIDI priorities
  NOTEON_PRIORITY  = 0
  NOTEOFF_PRIORITY = -1
  CC_PRIORITY      = -2
  PC_PRIORITY      = -3
  
  # A priority is a pair of (timestamp, level) with a lexicographical ordering.
  # The level is an Integer used to determine the order of execution of events
  # scheduled to run at the same time (lower level wins). The ordering of
  # simultaneous events with identical levels is undefined.
  class Priority < Struct.new(:time, :level)
    include Comparable
    
    def <=>(prio)
      self.to_a <=> prio.to_a
    end
  end
end
