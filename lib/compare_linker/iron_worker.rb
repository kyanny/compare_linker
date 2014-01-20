class CompareLinker
  class IronWorker
    def self.run
      puts "Starting CompareLinker::IronWorker at #{Time.now}"
      puts "Payload: #{params}"

      compare_linker = CompareLinker.new(params[:repo_full_name], params[:pr_number])
      compare_linker.formatter = CompareLinker::Formatter::Markdown.new
      compare_links = compare_linker.make_compare_links.join("\n")

      if compare_links.nil? || compare_links.empty?
        puts "no compare links"
      else
        comment_url = compare_linker.add_comment(payload.repo_full_name, payload.pr_number, compare_links)
        puts comment_url
      end

      puts "CompareLinker::IronWorker completed at #{Time.now}"
    end
  end
end

CompareLinker::IronWorker.run
