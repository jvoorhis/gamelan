module Gamelan
  # The scheduler allows the user to schedule tasks, represented
  # by +Gamelan::Task+.
  class Scheduler < Timer
    # Construct a new scheduler. +Scheduler#run+ must be called explicitly once
    # a Scheduler is created. Accepts two options, +:tempo+ and +:rate+.
    # [+:tempo+] The tempo's scheduler, in bpm. For example, at +:tempo => 120+,
    #            the scheduler's logical +phase+ will advance by 2.0 every 60
    #            seconds.
    # [+:rate+]  Frequency in Hz at which the scheduler will attempt to run
    #            ready tasks. For example, The scheduler will poll for tasks 100
    #            times in one second when +:rate+ is 100.
    def initialize(options = {})
      super
      @queue = Gamelan::Queue.new(self)
    end
    
    # Schedule a task to be performed at +delay+ beats. See Task.new for options.
    def at(delay, options = {}, &task)
      options = { :delay => delay, :scheduler => self }.merge(options)
      @queue << Task.new(options, &task)
    end
    
    protected
      # Run all ready tasks.
      def dispatch
        @queue.pop.run while @queue.ready?
      end
  end
end
