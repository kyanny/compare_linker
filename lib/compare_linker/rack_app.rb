require "sinatra/base"
require "compare_linker"
require "compare_linker/webhook_payload"

class CompareLinker
  class RackApp < Sinatra::Base
    get "/" do
      require 'pp'
      pp request.env
      warn request.env
    end

    post "/webhook" do
      require 'pp'
      payload = CompareLinker::WebhookPayload.new(params["payload"])
      pp payload
      if payload.action == "opened"
        compare_linker = CompareLinker.new(payload.repo_full_name, payload.pr_number)
        compare_linker.formatter = CompareLinker::Formatter::Markdown.new
        compare_links = compare_linker.make_compare_links.join("\n")
        pp compare_links
        pp [payload.repo_full_name, payload.pr_number, compare_links]
        comment_url = compare_linker.add_comment(payload.repo_full_name, payload.pr_number, compare_links)
        comment_url
      end
    end
  end
end
