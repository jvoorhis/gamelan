require 'gamelan/queue'

module Gamelan
  # The scheduler is responsible for scheduling tasks and running them as accurately as possible.
  class Scheduler
    include Java
    include_package 'java.util.concurrent'
    include_package 'java.lang'
    JavaThread = java.lang.Thread
    
    attr_reader :phase, :rate, :time
    
    # Construct a new scheduler. +Scheduler#run+ must be called explicitly once a Scheduler is created. Accepts two options, +:tempo+ and +:rate+.
    # [+:tempo+] The tempo's scheduler, in bpm. For example, at +:tempo => 120+, the scheduler's logical +phase+ will advance by 2.0 every 60 seconds.
    # [+:rate+]  Frequency in Hz at which the scheduler will attempt to run ready tasks. For example, The scheduler will poll for tasks 100 times in one
    #            second when +:rate+ is 100.
    def initialize(options = {})
      self.tempo = options.fetch(:tempo, 120)
      @rate      = (1.0 / options.fetch(:rate, 1000)) * 10 ** 9
      @queue     = Gamelan::Queue.new(self)
      @work      = LinkedBlockingQueue.new
      @worker    = Thread.new { loop { @work.take.run } }
    end
    
    # Initialize the scheduler's clock, and begin executing tasks.
    def run
      return if @running
      @running  = true
      @thread   = Thread.new do
        @phase  = 0.0
        @origin = @time = System.nano_time
        loop { dispatch; advance }
      end
    end
    
    # Halt the scheduler. Note that the scheduler may be restarted, but is
    # not resumable.
    def stop
      @running = false
      @thread.kill
    end
    
    # Schedule a task to be performed at +delay+ beats.
    def at(delay, *params, &task)
      @queue << Task.new(self, delay.to_f, *params, &task)
    end
    
    # Current tempo, in bpm.
    def tempo
      @tempo * 60.0
    end
    
    # Set the tempo in bpm.
    def tempo=(bpm)
      @tempo = bpm / 60.0
    end
    
    private
      # Advances the internal clock time and busywaits until it is reached.
      def advance
        @time   += @rate
        @phase  += (@time - @origin) * @tempo
        @origin  = @time
        JavaThread.yield until System.nano_time >= time
      end
      
      # Run all ready tasks.
      def dispatch
        @work.put(@queue.pop) while @queue.ready?
      end
  end
end
