
module Gamelan
  class Queue
    include Java
    include_package 'java.util'
    
    def initialize(sched)
      @scheduler = sched
      @queue     = PriorityQueue.new(10000) { |a,b| a.delay <=> b.delay }
    end
    
    def push(task)
      @queue.add(task)
    end
    alias << push
    
    def pop
      @queue.remove
    end
    
    def ready?
      @queue.peek && @queue.peek.delay < @scheduler.phase
    end
  end
end
