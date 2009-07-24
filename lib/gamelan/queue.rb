module Gamelan

  if jruby?
    
    class Queue
      include Java
      include_package 'java.util'
      
      def initialize(scheduler)
        @scheduler = scheduler
        @queue     = PriorityQueue.new(10000) { |a,b|
                       a.priority <=> b.priority
                     }
      end
      
      def push(task)
        @queue.add(task)
      end
      alias << push
      
      def pop
        @queue.remove
      end
      
      def ready?
        if top = @queue.peek
          top.delay < @scheduler.phase
        else
          false
        end
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
        @queue.push(task, task.priority)
      end
      alias << push
      
      def pop
        @queue.delete_min[0]
      end
      
      def ready?
        if top = @queue.min
          top[1].time < @scheduler.phase
        else
          false
        end
      end
    end

  end
end
