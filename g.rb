require "base64"
require "octokit"
require "bundler"
require 'pp'

repo_full_name, pr_number = *ARGV
repo_full_name = 'sanemat/bot-motoko-tachikoma'#'kyanny/compare_linker'
pr_number = 15#2
octokit = Octokit::Client.new(access_token: `git config ghn.token`.chomp)

if octokit.pull_request_files(repo_full_name, pr_number).find { |resource| resource.filename == "Gemfile.lock" }
  pull_request = octokit.pull_request(repo_full_name, pr_number)

  old_content = octokit.contents(
    repo_full_name, { ref: pull_request.base.sha }
  ).find { |content|
    content.name == "Gemfile.lock"
  }
  old_lockfile = Bundler::LockfileParser.new(
    Base64.decode64(octokit.blob(repo_full_name, old_content.sha).content)
  )

  new_content = octokit.contents(
    repo_full_name, { ref: pull_request.head.sha }
  ).find { |content|
    content.name == "Gemfile.lock"
  }
  new_lockfile = Bundler::LockfileParser.new(
    Base64.decode64(octokit.blob(repo_full_name, new_content.sha).content)
  )

  updated_gems = {}
  old_lockfile.specs.each do |old_spec|
    new_lockfile.specs.each do |new_spec|
      if (old_spec.name == new_spec.name) && (old_spec.version != new_spec.version)
        if old_spec.source.options["revision"] && new_spec.source.options["revision"]
          _, owner, gem_name = old_spec.source.uri.match(/github\.com\/(\w+)\/(\w+)/).to_a
          updated_gems[old_spec.name] = {
            owner: owner,
            gem_name: gem_name,
            old_ver: old_spec.source.options["revision"],
            new_ver: new_spec.source.options["revision"],
          }
        else
          updated_gems[old_spec.name] = {
            owner: nil,
            gem_name: old_spec.name,
            old_ver: old_spec.version.to_s,
            new_ver: new_spec.version.to_s,
          }
        end
      end
    end
  end
  pp updated_gems
end
