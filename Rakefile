require_relative "lib/compare_linker/version"

desc "Bump version tag"
task :release do
  sh "git tag v#{CompareLinker::VERSION}"
  sh "git push --tags"
end
