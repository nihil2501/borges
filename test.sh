#!/usr/bin/env ruby

path = "./test/tests"
Dir.each_child(path) do |file|
  require "#{path}/#{file}"
end