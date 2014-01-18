require "json"

class CompareLinker
  class WebhookPayload
    def initialize(payload)
      @payload = payload
      @json = JSON.parse(@payload)
    end

    def repo_full_name
      @json["repository"]["full_name"]
    end

    def pr_number
      @json["number"]
    end
  end
end
