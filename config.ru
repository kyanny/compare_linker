$: << File.expand_path("lib")
require "compare_linker/rack_app"

CompareLinker::RackApp.run!
