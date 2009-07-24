# Gamelan is a good-enough soft real-time event scheduler, 
# written in Ruby, especially for music applications.
#
# Copyright (c) 2008 Jeremy Voorhis <jvoorhis@gmail.com>
#
# This code released under the terms of the MIT license.

def jruby?
  defined?(JRUBY_VERSION)
end

require 'rubygems'
require 'gamelan/timer'
require 'gamelan/queue'
require 'gamelan/scheduler'
require 'gamelan/priority'
require 'gamelan/task'
