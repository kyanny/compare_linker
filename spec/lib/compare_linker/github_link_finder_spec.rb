require "spec_helper"

describe CompareLinker::GithubLinkFinder do
  let(:octokit) { double.as_null_object }

  subject { described_class.new(octokit) }

  before do
    HTTPClient.stub_chain(:get, :body) { load_fixture("web_translate_it.json") }
  end

  describe "#find" do
    it "extracts repo_owner and repo_name without trailing slash" do
      subject.find("web_translate_it")
      expect(subject.repo_owner).to eq "atelierconvivialite"
      expect(subject.repo_name).to eq "webtranslateit"
    end
  end
end
