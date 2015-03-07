require "ostruct"

class CompareLinker
  class Formatter
    class Text
      def format(gem_info)
        g = OpenStruct.new(gem_info)

        text = case
        when g.owner && g.old_rev && g.new_rev
          "#{g.gem_name}: https://github.com/#{g.owner}/#{g.gem_name}/compare/#{g.old_rev}...#{g.new_rev}"
        when g.homepage_uri
          "#{g.gem_name} (#{g.homepage_uri}): #{g.old_ver} => #{g.new_ver}"
        when g.old_tag && g.new_tag
          "#{g.gem_name}: https://github.com/#{g.repo_owner}/#{g.repo_name}/compare/#{g.old_tag}...#{g.new_tag}"
        when g.repo_owner && g.repo_name
          "#{g.gem_name}: https://github.com/#{g.repo_owner}/#{g.repo_name} #{g.old_ver} => #{g.new_ver}"
        else
          "#{g.gem_name} (link not found): #{g.old_ver} => #{g.new_ver}"
        end

        if downgrade?(g.old_ver, g.new_ver, g.old_tag, g.new_tag)
          text += " (downgrade)"
        end

        text
      end

      private

      def downgrade?(old_ver, new_ver, old_tag, new_tag)
        Gem::Version.new(new_ver) < Gem::Version.new(old_ver) ||
          (old_tag && new_tag && Gem::Version.new(to_ver(new_tag)) < Gem::Version.new(to_ver(old_tag)))
      end

      def to_ver(tag)
        tag.sub(/\Av/, '')
      end
    end
  end
end
