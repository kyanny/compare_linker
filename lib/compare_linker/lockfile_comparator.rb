class CompareLinker
  class LockfileComparator
    attr_accessor :updated_gems

    def initialize
      @updated_gems = {}
    end

    def compare(old_lockfile, new_lockfile)
      old_lockfile.specs.each do |old_spec|
        new_lockfile.specs.each do |new_spec|
          if old_spec.name == new_spec.name
            old_rev = old_spec.source.options["revision"]
            new_rev = new_spec.source.options["revision"]
            if old_rev && new_rev && (old_rev != new_rev)
              _, owner, gem_name = old_spec.source.uri.match(/github\.com\/([^\/]+)\/([^.]+)/).to_a
              updated_gems[old_spec.name] = {
                owner: owner,
                gem_name: gem_name,
                old_ver: old_rev,
                new_ver: new_rev,
              }
            elsif old_spec.version != new_spec.version
              updated_gems[old_spec.name] = {
                owner: nil,
                gem_name: old_spec.name,
                old_ver: old_spec.version.to_s,
                new_ver: new_spec.version.to_s,
              }
            end
          end
        end
      end
      updated_gems
    end
  end
end
