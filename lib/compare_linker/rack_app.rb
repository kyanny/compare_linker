require "sinatra/base"
require "compare_linker"
require "compare_linker/webhook_payload"

class CompareLinker
  class RackApp < Sinatra::Base
    configure do
      enable :logging
    end

    get "/" do
      require 'pp'
      pp request.env
      warn request.env
    end

    post "/webhook" do
      payload = CompareLinker::WebhookPayload.new(params["payload"])

      if payload.action == "opened"
        logger.info "action=#{payload.action} repo_full_name=#{payload.repo_full_name} pr_number=#{payload.pr_number}"

        compare_linker = CompareLinker.new(payload.repo_full_name, payload.pr_number)
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

      compare_linker = CompareLinker.new(payload.repo_full_name, payload.pr_number)
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
end
