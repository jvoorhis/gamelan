require 'thread'
require 'gamelan/task'

module Gamelan
  class Scheduler
    attr_reader :phase, :queue, :rate, :thread, :time
    
    def initialize(options = {})
      self.tempo = options.fetch(:tempo, 120)
      @rate      = options.fetch(:rate, 0.001)
      @sleep_for = rate / 10.0
      @queue     = []
      @phase     = 0.0
      @origin    = @time = Time.now.to_f
      @lock      = Mutex.new
      
      @thread = Thread.new do
        loop { dispatch; advance }
      end
    end
    
    # Add a new job to be performed at +time+.
    def at(delay, *params, &task)
      @queue.push(Task.new(self, phase + delay.to_f, *params, &task))
    end

    def freeze(&block)
      @lock.synchronize(&block)
    end
    
    def tempo
      @tempo * 60.0
    end
    
    def tempo=(bpm)
      @tempo = bpm / 60.0
    end
    
    private
      # Advance the internal clock time and spin until it is reached.
      def advance
        @lock.synchronize do
          @time += @rate
          loop do
            break if Time.now.to_f > @time
            sleep(@sleep_for) # Don't saturate the CPU
          end
        end
      end
      
      def dispatch
        @phase  += (@time - @origin) * @tempo
        @origin  = @time
        ready, @queue = @queue.partition { |task| task.delay <= @phase }
        ready.each { |task| task.run }
      end
  end
end
