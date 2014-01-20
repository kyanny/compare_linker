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
      payload = CompareLinker::WebhookPayload.new(params["payload"])
      puts 1
      p [payload.action, payload.repo_full_name, payload.pr_number]
      if payload.action == "opened"
        puts 2
        compare_linker = CompareLinker.new(payload.repo_full_name, payload.pr_number)
        puts 3
        compare_linker.formatter = CompareLinker::Formatter::Markdown.new
        puts 4
        compare_links = compare_linker.make_compare_links.join("\n")
        puts 5
        puts compare_links
        # if compare_links.nil?
        #   puts "no compare links"
        # else
        #   comment_url = compare_linker.add_comment(payload.repo_full_name, payload.pr_number, compare_links)
        #   puts comment_url
        # end
      else
        puts 'x'
        puts payload.action
      end
    end
  end
end
