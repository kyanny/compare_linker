require "slim"
require "dotenv"
require "rack-flash"
require "sinatra/base"
require "iron_worker_ng"
require "omniauth-github"
require_relative "../compare_linker"
require_relative "webhook_payload"

class CompareLinker
  class RackApp < Sinatra::Base
    configure do
      enable :logging
      set :views, File.join(__dir__, '..', '..', 'views')
      set :public_folder, File.join(__dir__, '..', '..', 'public')
      Slim::Engine.default_options[:pretty] = true
      Dotenv.load
    end

    # keep this order - Rack::Session first, Rack::Flash later
    use Rack::Session::Cookie, secret: ENV["GITHUB_KEY"] + ENV["GITHUB_SECRET"]
    use Rack::Flash
    use OmniAuth::Builder do
      provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET'], scope: "public_repo"
    end

    get "/" do
      slim :index
    end

    post "/webhook" do
      payload = CompareLinker::WebhookPayload.new(params["payload"])

      if payload.action == "opened"
        logger.info "action=#{payload.action} repo_full_name=#{payload.repo_full_name} pr_number=#{payload.pr_number}"

        client = IronWorkerNG::Client.new
        client.tasks.create("make_and_post_compare_links", {
            repo_full_name: payload.repo_full_name,
            pr_number: payload.pr_number,
          })
      end
    end

    post "/webhook_backdoor" do
      repo_full_name = params["repo_full_name"]
      pr_number = params["pr_number"]
      logger.info "repo_full_name=#{repo_full_name} pr_number=#{pr_number}"

      client = IronWorkerNG::Client.new
      client.tasks.create("make_and_post_compare_links", {
          repo_full_name: repo_full_name,
          pr_number: pr_number,
        })
    end

    get "/auth/github/callback" do
      # auth = request.env["omniauth.auth"]
      # provider = auth["provider"]
      # uid = auth["uid"]
      # access_token = auth["credentials"]["token"]
      flash[:notice] = "Login successfully"
      redirect "/"
    end
  end
end
