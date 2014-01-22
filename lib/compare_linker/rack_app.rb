require "slim"
require "dotenv"
require "mongoid"
require "octokit"
require "rack-flash"
require "sinatra/base"
require "omniauth-github"
require_relative "../compare_linker"
require_relative "webhook_payload"

begin
  require "rack-ssl-enforcer"
rescue LoadError
end

class CompareLinker
  class Authorization
    include Mongoid::Document
    include Mongoid::Timestamps

    field :provider, type: String
    field :uid, type: String
    field :nickname, type: String

    has_one :credential
  end

  class Credential
    include Mongoid::Document
    include Mongoid::Timestamps

    field :token, type: String

    belongs_to :authorization
    has_many :repos
  end

  class Repo
    include Mongoid::Document
    include Mongoid::Timestamps

    field :repo_full_name, type: String

    belongs_to :credential
  end

  class RackApp < Sinatra::Base
    configure do
      enable :logging
      set :views, File.join(__dir__, "..", "..", 'views')
      set :public_folder, File.join(__dir__, "..", "..", 'public')
      Slim::Engine.default_options[:pretty] = true
      Dotenv.load
      Mongoid.load!(File.join(__dir__, "..", "..", 'config', 'mongoid.yml'))
    end

    configure :production do
      require "newrelic_rpm"
    end

    # keep this order - Rack::Session first, Rack::Flash later
    use Rack::SslEnforcer if ENV["RACK_ENV"].to_s.downcase == "production"
    use Rack::Session::Cookie, secret: ENV["GITHUB_KEY"] + ENV["GITHUB_SECRET"]
    use Rack::Flash
    use OmniAuth::Builder do
      provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET'], scope: "public_repo"
    end

    get "/" do
      if session["uid"]
        authorization = Authorization.find_by(uid: session["uid"])
        if authorization.credential
          octokit = Octokit::Client.new(access_token: authorization.credential.token)
          octokit.auto_paginate = true
          @repos = octokit.repos(nil, {sort: "created"})
        end
      end
      slim :index
    end

    post "/webhook" do
      logger.info params
      payload = CompareLinker::WebhookPayload.new(params["payload"])

      if payload.action == "opened"
        logger.info "action=#{payload.action} repo_full_name=#{payload.repo_full_name} pr_number=#{payload.pr_number}"

        repo = Repo.find_by_repo_full_name(payload.repo_full_name)
        if repo.credential
          access_token = repo.credential.token
          octokit = Octokit::Client.new(access_token: access_token)
        end

        compare_linker = CompareLinker.new(payload.repo_full_name, payload.pr_number)
        if octokit
          compare_linker.octokit = octokit
        end
        compare_linker.formatter = CompareLinker::Formatter::Markdown.new
        compare_links = compare_linker.make_compare_links.join("\n")

        if compare_links.nil? || compare_links.empty?
          logger.info "no compare links"
        else
          comment_url = compare_linker.add_comment(payload.repo_full_name, payload.pr_number, compare_links)
          logger.info comment_url
        end
      end
    end

    post "/webhook_backdoor" do
      repo_full_name = params["repo_full_name"]
      pr_number = params["pr_number"]
      logger.info "repo_full_name=#{repo_full_name} pr_number=#{pr_number}"

      repo = Repo.find_by(repo_full_name: repo_full_name)
      if repo && repo.credential
        access_token = repo.credential.token
        octokit = Octokit::Client.new(access_token: access_token)
      end

      compare_linker = CompareLinker.new(repo_full_name, pr_number)
      if octokit
        compare_linker.octokit = octokit
      end
      compare_linker.formatter = CompareLinker::Formatter::Markdown.new
      compare_links = compare_linker.make_compare_links.join("\n")

      if compare_links.nil? || compare_links.empty?
        logger.info "no compare links"
      else
        comment_url = compare_linker.add_comment(repo_full_name, pr_number, compare_links)
        logger.info comment_url
      end
    end

    post "/add_webhook" do
      halt unless params["repo_full_name"]

      authorization = Authorization.find_by(uid: session["uid"])
      credential = authorization.credential
      repos = credential.repos
      if repos.none? { |repo| reop.full_name == params["repo_full_name"] }
        octokit = Octokit::Client.new(access_token: authorization.credential.token)
        octokit.create_hook(
          params["repo_full_name"],
          "web",
          {
            url: "https://#{request.host}/webhook",
            content_type: "json",
          },
          {
            events: ["pull_request"],
            active: true,
          }
        )
        Repo.find_or_create_by(
          credential: credential,
          repo_full_name: params["repo_full_name"],
        )
        "ok"
      else
        halt
      end
    end

    get "/auth/github/callback" do
      auth = request.env["omniauth.auth"]
      authorization = Authorization.find_or_create_by(
        provider: auth["provider"],
        uid: auth["uid"],
        nickname: auth["info"]["nickname"],
      )
      credential = Credential.find_or_create_by(
        authorization: authorization,
        token: auth["credentials"]["token"],
      )
      logger.info "provider=#{auth['provider']} uid=#{auth['uid']} nickname=#{auth['info']['nickname']} authorization=#{authorization.id} credential=#{credential.id}"
      session[:uid] = auth["uid"]
      flash[:notice] = "Login successfully"
      redirect "/"
    end
  end
end
