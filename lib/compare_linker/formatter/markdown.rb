require "ostruct"

class CompareLinker
  class Formatter
    class Markdown
      def format(gem_info)
        g = OpenStruct.new(gem_info)

        text = case
        when g.owner
          "* #{g.gem_name}: https://github.com/#{g.owner}/#{g.gem_name}/compare/#{g.old_ver}...#{g.new_ver}"
        when g.homepage_uri
          "* [#{g.gem_name}](#{g.homepage_uri}): #{g.old_ver} => #{g.new_ver}"
        when g.old_tag && g.new_tag
          "* #{g.gem_name}: https://github.com/#{g.repo_owner}/#{g.repo_name}/compare/#{g.old_tag}...#{g.new_tag}"
        when g.repo_owner && g.repo_name
          "* [#{g.gem_name}](https://github.com/#{g.repo_owner}/#{g.repo_name}): #{g.old_ver} => #{g.new_ver}"
        else
          "* #{g.gem_name}: (link not found) #{g.old_ver} => #{g.new_ver}"
        end

        if (g.old_tag && g.new_tag && g.new_tag.to_f < g.old_tag.to_f) || g.new_ver.to_f < g.old_ver.to_f
          text += " (downgrade)"
        end

        text
      end
    end
  end
end
