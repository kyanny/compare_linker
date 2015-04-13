require "spec_helper"

describe CompareLinker::GithubLinkFinder do
  let(:octokit) { double.as_null_object }

  subject { described_class.new(octokit) }


  describe "#find" do
    before do
      allow(HTTPClient).to receive(:get_content).and_return load_fixture("rails.json")
      allow(subject).to receive(:redirect_url).and_return "http://github.com/rails/rails"
    end

    it "extracts repo_owner and repo_name" do
      subject.find("rails")
      expect(subject.repo_owner).to eq "rails"
      expect(subject.repo_name).to eq "rails"
    end

    context "if github url includes trailing slash" do
      before do
        allow(HTTPClient).to receive(:get_content).and_return load_fixture("web_translate_it.json")
        allow(subject).to receive(:redirect_url).and_return "http://github.com/atelierconvivialite/webtranslateit/"
      end

      it "extracts repo_owner and repo_name without trailing slash" do
        subject.find("web_translate_it")
        expect(subject.repo_owner).to eq "atelierconvivialite"
        expect(subject.repo_name).to eq "webtranslateit"
      end
    end

    context "if gem not found on rubygems.org" do
      before do
        exception = HTTPClient::BadResponseError.new "unexpected response:..."
        allow(HTTPClient).to receive(:get_content).and_raise exception
      end

      it "extracts homepage_uri" do
        subject.find("not_found")
        expect(subject.homepage_uri).to eq "https://rubygems.org/gems/not_found"
      end
    end

    context "if homepage_uri is '404 not found'" do
      before do
        allow(HTTPClient).to receive(:get_content).and_return load_fixture("coffee-script-source.json")
        allow(subject).to receive(:redirect_url).and_return nil
      end

      it "extracts homepage_uri" do
        subject.find("coffee-script-source")
        expect(subject.homepage_uri).to eq "http://jashkenas.github.com/coffee-script/"
      end
    end
  end
end
