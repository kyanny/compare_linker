require "bundler"

class CompareLinker
  class LockfileFetcher
    attr_reader :octokit

    def initialize(octokit)
      @octokit = octokit
    end

    def fetch(repo_full_name, ref)
      lockfile_content = octokit.contents(
        repo_full_name, { ref: ref }
      ).find { |content|
        content.name == "Gemfile.lock"
      }
      Bundler::LockfileParser.new(
        Base64.decode64(
          octokit.blob(repo_full_name, lockfile_content.sha).content
        )
      )
    end
  end
end
