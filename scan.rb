require 'pp'
require "strscan"

gems = Hash.new { |h,k| h[k] = {} }

scanner = StringScanner.new(File.read("test/fixtures/multi.diff"))
scan(scanner, gems)

scanner = StringScanner.new(File.read("test/fixtures/git.diff"))
scan(scanner, gems)

pp gems
