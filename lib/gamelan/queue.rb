module Gamelan

  if jruby?
    
    class Queue
      include Java
      include_package 'java.util.concurrent'
      
      def initialize(sched)
        @scheduler = sched
        comparator = lambda { |a,b| a.delay <=> b.delay }
        @queue     = PriorityBlockingQueue.new(10000, &comparator)
        @lock      = Mutex.new
      end
      
      def push(task)
        @lock.synchronize { @queue.add(task) }
      end
      alias << push
      
      def pop
        @lock.synchronize { @queue.remove }
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
