require 'forwardable'

module Gamelan

  # Tasks run by the Scheduler. A task is a combination of a block to be
  # run, a delay, in beats, that specifies when to run the Task, and an
  # optional list of args. A reference to the Scheduler is also stored, so it
  # can be manipulatd by tasks.
  class Task
    extend Forwardable
    def_delegators :@scheduler, :at, :phase, :rate, :time
    attr_reader :delay, :args, :scheduler
    
    # Construct a Task with a Scheduler reference, a delay in beats, an
    # optional list of args, and a block.
    def initialize(sched, delay, *args, &block)
      @scheduler, @delay, @proc, @args = sched, delay, block, args
    end
    
    # The scheduler will invoke Task#run is called with the Task's +delay+ at
    # the scheduled time. Any optional +args+, if given, will follow.
    # are yielded to the block.
    def run; @proc[@delay, *@args] end
  end
end
