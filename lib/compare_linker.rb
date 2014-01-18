require "json"
require "octokit"
require "httpclient"
require "unified_diff"
require_relative "compare_linker/webhook_payload"

class CompareLinker
  attr_reader :repo_full_name, :pr_number, :octokit

  def initialize(repo_full_name, pr_number)
    @repo_full_name = repo_full_name
    @pr_number = pr_number
    @octokit   = Octokit::Client.new # need to set OCTOKIT_ACCESS_TOKEN env
  end

  def make_compare_link
    UnifiedDiff.parse(
      octokit.pull_request_files(repo_full_name, pr_number).find { |resource| resource.filename == "Gemfile.lock" }.patch
    ).chunks.map { |chunk, i|
      old = chunk.raw_lines.find { |line| line.match(/^-/) } # TODO: `find` ignore dependency updates
      new = chunk.raw_lines.find { |line| line.match(/^\+/) }
      _, old_gem, old_ver = old.match(/^-\s+(\S+) \((.*?)\)/).to_a
      _, new_gem, new_ver = new.match(/^\+\s+(\S+) \((.*?)\)/).to_a
      gem = [old_gem, new_gem].uniq.first
      if gem.nil?
        _, owner, gem = chunk.raw_lines.find { |line| line.match(/github\.com/) }.match(/github\.com\/(.*)\/(.*)\.git/).to_a
        _, old_ver = old.match(/^-\s+revision:\s+(\S+)/).to_a
        _, new_ver = new.match(/^\+\s+revision:\s+(\S+)/).to_a
      end
      next if (old_ver.nil? || new_ver.nil?)
      if owner.nil?
        gem_info = JSON.parse(
          HTTPClient.get("https://rubygems.org/api/v1/gems/#{gem}.json").body
        )
        # github_url = [gem_info["homepage_uri"], gem_info["source_code_uri"]].find { |uri| uri.match(/github\.com\/.*\/#{gem}$/) }
        github_url = [gem_info["homepage_uri"], gem_info["source_code_uri"]].find { |uri| uri.match(/github\.com\//) } # newrelic/rpm
        if github_url.nil?
          "* [#{gem}](#{gem_info["homepage_uri"]}): #{old_ver} => #{new_ver}"
        else
          _, github_repo = github_url.match(/github\.com\/(.*\/.*)/).to_a
          tags = octokit.tags(github_repo)
          old_tag = tags.find { |tag| tag.name == old_ver || tag.name == "v#{old_ver}" }
          new_tag = tags.find { |tag| tag.name == new_ver || tag.name == "v#{new_ver}" }
          if old_tag && new_tag
            "* #{gem}: #{github_url}/compare/#{old_tag.name}...#{new_tag.name}"
          else
            "* [#{gem}](#{github_url}): #{old_ver} => #{new_ver}"
          end
        end
      else
        "* #{gem}: https://github.com/#{owner}/#{gem}/compare/#{old_ver}...#{new_ver}"
      end
    }.compact
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
