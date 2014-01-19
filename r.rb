require_relative "lib/compare_linker"
#require_relative "lib/compare_linker/webhook_payload"

# payload = CompareLinker::WebhookPayload.new(ENV["payload"])
# exit if payload.action != "opened"

ENV["OCTOKIT_ACCESS_TOKEN"] = `git config ghn.token`.chomp

[
  # ['sanemat/bot-motoko-tachikoma', 15],
  # ['kyanny/compare_linker', 2],
  ['quipper/api', 589],
].each do |pair|
  puts "="*80
  compare_linker = CompareLinker.new(*pair)
  puts compare_linker.make_compare_links

  # puts "="*80
  # compare_linker = CompareLinker.new(*pair)
  # compare_linker.formatter = CompareLinker::Formatter::Markdown.new
  # puts compare_linker.make_compare_links

  # puts "-"*80
  # puts "-"*80
end

# puts compare_linker.add_comment(payload.repo_full_name, payload.pr_number, compare_links)
