require "spec_helper"

describe CompareLinker::GithubLinkFinder do
  let(:octokit) { double.as_null_object }

  subject { described_class.new(octokit) }


  describe "#find" do
    before do
      allow(HTTPClient).to receive_message_chain(:get, :body).and_return load_fixture("rails.json")
    end

    it "extracts repo_owner and repo_name" do
      subject.find("rails")
      expect(subject.repo_owner).to eq "rails"
      expect(subject.repo_name).to eq "rails"
    end

    context "if github url includes trailing slash" do
      before do
        allow(HTTPClient).to receive_message_chain(:get, :body).and_return load_fixture("web_translate_it.json")
      end

      it "extracts repo_owner and repo_name without trailing slash" do
        subject.find("web_translate_it")
        expect(subject.repo_owner).to eq "atelierconvivialite"
        expect(subject.repo_name).to eq "webtranslateit"
      end
    end
  end
end
