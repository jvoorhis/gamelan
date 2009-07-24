require 'forwardable'

module Gamelan

  # Tasks run by the Scheduler. A task is a combination of a block to be
  # run, a delay, in beats, that specifies when to run the Task, and an
  # optional list of args. A reference to the Scheduler is also stored, so it
  # can be manipulatd by tasks.
  class Task
    extend Forwardable
    def_delegators :@scheduler, :at, :phase, :rate, :time
    attr_reader :delay, :level, :priority, :args, :scheduler
    
    # Construct a Task from a block and an options Hash. Options are:
    # [+:scheduler+] A reference to the scheduler.
    # [+:delay+]     The logical time when the task will be run.
    # [+:level+]     A level for determining the order of execution for events scheduled at the same time (optional).
    # [+:args+]      Arguments that will be passed into the block (optional).
    def initialize(options, &block)
      @scheduler = options[:scheduler]
      @delay     = options[:delay].to_f
      @level     = options[:level] || DEFAULT_PRIORITY
      @priority  = Priority.new(@delay, @level)
      @proc      = block
      @args      = options[:args] || []
    end
    
    # The scheduler will invoke Task#run is called with the Task's +delay+ at
    # the scheduled time. Any optional +args+, if given, will follow.
    # are yielded to the block.
    def run
      @proc.call(@delay, *@args)
    end
  end
end
