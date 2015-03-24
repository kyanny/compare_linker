require "json"
require "httpclient"
require "net/http"

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
        github_url = redirect_url(github_url)
        _, @repo_owner, @repo_name = github_url.match(%r!github\.com/([^/]+)/([^/]+)!).to_a
      end

    rescue JSON::ParserError
      @homepage_uri = "https://rubygems.org/gems/#{gem_name}"
    end

    def repo_full_name
      "#{@repo_owner}/#{repo_name}"
    end

    private

    def redirect_url(url, limit = 5)
      raise ArgumentError, 'HTTP redirect too deep' if limit <= 0
      response = Net::HTTP.get_response(URI.parse(url))
      case response
      when Net::HTTPSuccess
        url
      when Net::HTTPRedirection
        redirect_url(response['location'], limit - 1)
      else
        raise ItemNotFound
      end
    end
  end
end
