require "json"
require "httpclient"

class CompareLinker
  class GithubLinkFinder
    attr_reader :octokit, :repo_owner, :repo_name, :homepage_uri

    def initialize(octokit)
      @octokit = octokit
    end

    def find(gem_name)
      gem_info = JSON.parse(
        HTTPClient.get("https://rubygems.org/api/v1/gems/#{gem_name}.json").body
      )

      github_url = [
        gem_info["homepage_uri"],
        gem_info["source_code_uri"]
      ].find { |uri| uri.to_s.match(/github\.com\//) }

      if github_url.nil?
        @homepage_uri = gem_info["homepage_uri"]
      else
        _, @repo_owner, @repo_name = github_url.match(/github\.com\/(\w+)\/(.*)/).to_a
      end
    end

    def repo_full_name
      "#{@repo_owner}/#{repo_name}"
    end
  end
end
