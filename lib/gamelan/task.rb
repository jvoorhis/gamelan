require 'forwardable'

module Gamelan

  # Tasks are run by the Scheduler. A task is a combination of a block to be
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
    
    # Task#run is yielded within the scope of the Task when the Scheduler is
    # ready. Any optional +args+ are yielded to the block.
    def run
      instance_exec(*@args, &@proc)
    end
  end
end
