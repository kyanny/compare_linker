require "json"
require "octokit"
require "httpclient"
require "unified_diff"
require_relative "compare_linker/lockfile_fetcher"
require_relative "compare_linker/lockfile_comparator"
require_relative "compare_linker/github_link_finder"
require_relative "compare_linker/github_tag_finder"
require_relative "compare_linker/formatter/text"
require_relative "compare_linker/formatter/markdown"

class CompareLinker
  attr_reader :repo_full_name, :pr_number, :octokit
  attr_accessor :formatter

  def initialize(repo_full_name, pr_number)
    @repo_full_name = repo_full_name
    @pr_number = pr_number
    @octokit   = Octokit::Client.new(access_token: ENV["OCTOKIT_ACCESS_TOKEN"]) # need to set OCTOKIT_ACCESS_TOKEN env
    @formatter = Formatter::Text.new
  end

  def make_compare_links
    if octokit.pull_request_files(repo_full_name, pr_number).find { |resource| resource.filename == "Gemfile.lock" }
      pull_request = octokit.pull_request(repo_full_name, pr_number)

      fetcher = LockfileFetcher.new(octokit)
      old_lockfile = fetcher.fetch(repo_full_name, pull_request.base.sha)
      new_lockfile = fetcher.fetch(repo_full_name, pull_request.head.sha)

      comparator = LockfileComparator.new
      comparator.compare(old_lockfile, new_lockfile)
      comparator.updated_gems.map { |gem_name, gem_info|
        if gem_info[:owner].nil?
          finder = GithubLinkFinder.new(octokit)
          finder.find(gem_name)
          if finder.repo_owner.nil?
            gem_info[:homepage_uri] = finder.homepage_uri
            formatter.format(gem_info)
          else
            gem_info[:repo_owner] = finder.repo_owner
            gem_info[:repo_name] = finder.repo_name

            tag_finder = GithubTagFinder.new(octokit)
            old_tag = tag_finder.find(finder.repo_full_name, gem_info[:old_ver])
            new_tag = tag_finder.find(finder.repo_full_name, gem_info[:new_ver])

            if old_tag && new_tag
              gem_info[:old_tag] = old_tag.name
              gem_info[:new_tag] = new_tag.name
              formatter.format(gem_info)
            else
              formatter.format(gem_info)
            end
          end
        else
          formatter.format(gem_info)
        end
      }
    end
  end

  def add_comment(repo_full_name, pr_number, compare_links)
    res = octokit.add_comment(
      repo_full_name,
      pr_number,
      compare_links
    )
    "https://github.com/#{repo_full_name}/pull/#{pr_number}#issuecomment-#{res.id}"
  end
end
