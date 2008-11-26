require 'forwardable'

module Gamelan
  
  class Task
    extend Forwardable
    def_delegators :@scheduler, :at, :freeze, :phase, :rate, :thread, :time
    attr_reader :delay, :params, :scheduler
    
    def initialize(sched, delay, *params, &proc)
      @scheduler, @delay, @proc, @params = sched, delay, proc, params
    end
    
    def run
      instance_exec(*params, &@proc)
    end
  end
end
