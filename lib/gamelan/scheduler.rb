require 'gamelan/queue'

module Gamelan
  # The scheduler is responsible for scheduling tasks and running them as accurately as possible.
  class Scheduler
    attr_reader :phase, :rate, :time
    
    # Construct a new scheduler. +Scheduler#run+ must be called explicitly once a Scheduler is created. Accepts two options, +:tempo+ and +:rate+.
    # [+:tempo+] The tempo's scheduler, in bpm. For example, at +:tempo => 120+, the scheduler's logical +phase+ will advance by 2.0 every 60 seconds.
    # [+:rate+]  Frequency in Hz at which the scheduler will attempt to run ready tasks. For example, The scheduler will poll for tasks 100 times in one
    #            second when +:rate+ is 100.
    def initialize(options = {})
      self.tempo = options.fetch(:tempo, 120)
      @rate      = 1.0 / options.fetch(:rate, 1000)
      @sleep_for = rate / 10.0
      @queue     = Gamelan::Queue.new(self)
    end
    
    # Initialize the scheduler's clock, and begin executing tasks.
    def run
      return if @running
      @running  = true
      @thread   = Thread.new do
        @phase  = 0.0
        @origin = @time = Time.now.to_f
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

    def join; @thread.join end
    
    private
      # Advances the internal clock time and spins until it is reached.
      def advance
        @time   += @rate
        @phase  += (@time - @origin) * @tempo
        @origin  = @time
        sleep(@sleep_for) until Time.now.to_f >= @time
      end
      
      # Run all ready tasks.
      def dispatch
        @queue.pop.run while @queue.ready?
      end
  end
end
