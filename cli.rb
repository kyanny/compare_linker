require_relative "compare_linker"

def usage
  <<USAGE
Usage: OCTOKIT_ACCESS_TOKEN=[your github token] ruby #{$0} [repo_full_name] [pr_number]
USAGE
end

repo_full_name, pr_number = *ARGV
if repo_full_name.nil? || pr_number.nil?
  puts usage
  exit(1)
end

puts CompareLinker.new(repo_full_name, pr_number).make_compare_link
