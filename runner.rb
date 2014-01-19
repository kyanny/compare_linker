require_relative "lib/compare_linker"
require "optparse"

repo_full_name, pr_number = *ARGV
if repo_full_name.nil? || pr_number.nil?
  puts <<USAGE
Usage: ruby #{0} [repo_full_name] [pr_number]
       ruby #{0} [repo_full_name] [pr_number] OCTOKIT_ACCESS_TOKEN=[your github access token]
USAGE
  exit!
end

compare_linker = CompareLinker.new(repo_full_name, pr_number.to_i)

opt = OptionParser.new
opt.on("-f VAL", "--format VAL") { |val|
  case val
  when /t(ext)?/i
    compare_linker.formatter = CompareLinker::Formatter::Text.new
  when /m(arkdown|d)?/i
    compare_linker.formatter = CompareLinker::Formatter::Markdown.new
  end
}
opt.on("--post-comment") {
  at_exit do
    puts compare_linker.add_comment(repo_full_name, pr_number, compare_linker.compare_links)
  end
}
opt.parse!

puts compare_linker.make_compare_links
