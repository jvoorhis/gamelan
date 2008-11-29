require 'priority_queue/c_priority_queue'
require 'priority_queue'

module Gamelan
  class Queue
    def initialize(sched)
      @scheduler = sched
      @queue     = ::PriorityQueue.new
    end
    
    def push(task)
      @queue.push(task, task.delay)
    end
    alias << push
    
    def pop
      @queue.delete_min[0]
    end
    
    def ready?
      @queue.min && @queue.min[1] < @scheduler.phase
    end
  end
end
