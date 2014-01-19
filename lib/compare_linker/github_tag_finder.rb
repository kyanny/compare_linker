class CompareLinker
  class GithubTagFinder
    attr_reader :octokit

    def initialize(octokit)
      @octokit = octokit
    end

    def find(repo_full_name, gem_version)
      tags = octokit.tags(repo_full_name)
      if tags
        tags.find { |tag|
          tag.name == gem_version || tag.name == "v#{gem_version}"
        }
      end
    end
  end
end
