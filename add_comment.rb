require_relative "lib/compare_linker"

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

compare_linker = CompareLinker.new(repo_full_name, pr_number)
compare_links = compare_linker.make_compare_link.join("\n")
puts compare_linker.add_comment(repo_full_name, pr_number, compare_links)
