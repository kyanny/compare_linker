require "rspec/core/rake_task"
require_relative "lib/compare_linker/version"

RSpec::Core::RakeTask.new("spec")
task :default => :spec

desc "Bump version tag"
task :release do
  sh "git tag v#{CompareLinker::VERSION}"
  sh "git push --tags"
end
