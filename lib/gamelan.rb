# Gamelan is a good-enough soft real-time event scheduler, 
# written in Ruby, especially for music applications.
#
# Copyright (c) 2008 Jeremy Voorhis <jvoorhis@gmail.com>
#
# This code released under the terms of the MIT license.

require 'gamelan/scheduler'

class Object
  
  unless methods.include?('instance_exec')
    # Like instace_eval but allows parameters to be passed.
    # Implementation taken from http://eigenclass.org/hiki.rb?instance_exec
    def instance_exec(*args, &block)
      mname = "__instance_exec_#{Thread.current.object_id.abs}_#{object_id.abs}"
      Object.class_eval{ define_method(mname, &block) }
      begin
        ret = send(mname, *args)
      ensure
        Object.class_eval{ undef_method(mname) } rescue nil
      end
      ret
    end
  end
end
