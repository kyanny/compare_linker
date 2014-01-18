require_relative "lib/compare_linker/webhook_payload"

def usage
  <<USAGE
Usage: ruby #{$0} payload.json
       cat payload.json | ruby #{$0}
USAGE
end

payload = CompareLinker::WebhookPayload.new(ARGF.read)
puts "#{payload.repo_full_name} #{payload.pr_number}"
