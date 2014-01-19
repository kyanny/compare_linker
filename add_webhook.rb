require "octokit"

repo_full_name, webhook_url = *ARGV
if repo_full_name.nil? || webhook_url.nil? || ENV["OCTOKIT_ACCESS_TOKEN"].nil?
  puts <<USAGE
Usage: OCTOKIT_ACCESS_TOKEN=[your github access token] ruby #{$0} [repo_full_name] [webhook_url]
USAGE
  exit!
end

require 'pp'
octokit = Octokit::Client.new(access_token: ENV["OCTOKIT_ACCESS_TOKEN"])
res = octokit.create_hook(
  repo_full_name,
  "web",
  {
    url: webhook_url,
  },
  {
    events: ["pull_request"],
    active: true,
  }
)
if res.active
  puts "Webhook added: https://github.com/#{repo_full_name}/settings/hooks"
end
