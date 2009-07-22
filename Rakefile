$:.unshift 'lib'
require 'rake/gempackagetask'

desc 'Execrise Gamelan by running the benchmark'
task :default do
  load 'benchmark/benchmark.rb'
end

def spec
  Gem::Specification.load('gamelan.gemspec')
end

Rake::GemPackageTask.new(spec) { |task| }
