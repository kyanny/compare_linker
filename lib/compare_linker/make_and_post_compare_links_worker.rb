require_relative "lib/compare_linker"
require "octokit"

puts "Starting CompareLinker::IronWorker at #{Time.now}"
puts "Payload: #{params}"

octokit = Octokit::Client.new(access_token: params["access_token"])
compare_linker = CompareLinker.new(params["repo_full_name"], params["pr_number"])
compare_linker.octokit = octokit
compare_linker.formatter = CompareLinker::Formatter::Markdown.new
compare_links = compare_linker.make_compare_links.join("\n")

if compare_links.nil? || compare_links.empty?
  puts "no compare links"
else
  comment_url = compare_linker.add_comment(payload.repo_full_name, payload.pr_number, compare_links)
  puts comment_url
end

puts "CompareLinker::IronWorker completed at #{Time.now}"
