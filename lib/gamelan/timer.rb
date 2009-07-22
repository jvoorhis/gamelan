module Gamelan
  # The Timer is responsible for executing code at a fixed rate. Users must
  # subclass +Gamelan::Timer+. See +Gamelan::Scheduler+ for an example.
  class Timer
    attr_reader :phase, :rate, :time
    
    # Construct a new timer. +Timer#run+ must be called explicitly once a Timer
    # is created. Accepts two options, +:tempo+ and +:rate+.
    # [+:tempo+] The timer's tempo, in bpm. For example, at +:tempo => 120+,
    # the timer's logical +phase+ will advance by 2.0 every 60 seconds.
    # [+:rate+]  Frequency in Hz at which the scheduler will dispatch.
    def initialize(options = {})
      self.tempo = options.fetch(:tempo, 120)
      @rate      = 1.0 / options.fetch(:rate, 440.0)
      @sleep_for = rate / options.fetch(:granularity, 1.0)
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
        raise NotImplementedError, "subclass responsibility"
      end
  end
end
