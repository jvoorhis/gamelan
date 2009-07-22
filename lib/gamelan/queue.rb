module Gamelan

  if jruby?
    
    class Queue
      include Java
      include_package 'java.util'
      
      def initialize(sched)
        @scheduler = sched
        comparator = lambda { |a,b| a.delay <=> b.delay }
        @queue     = PriorityQueue.new(10000, &comparator)
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
    
  else
    
    require 'priority_queue/c_priority_queue'
    require 'priority_queue'
    
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
end
