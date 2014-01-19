require "strscan"

class CompareLinker
  class LockfileDiffScanner
    attr_accessor :scanner, :gems

    def initialize(diff_string)
      @scanner = StringScanner.new(diff_string)
      @gems = Hash.new { |h,k| h[k] = {} }
    end

    def scan
      while !scanner.eos?
        case
        when scanner.scan(/^---/)     # ignore diff chunk header
          scanner.skip_until(/\n/)
        when scanner.scan(/^\+\+\+/)  # ignore diff chunk header
          scanner.skip_until(/\n/)
        when scanner.scan(/^\s+remote:(.*)/)
          # match such block:
          #    remote: git://github.com/sanemat/tachikoma.git
          # -  revision: 3cbbfbcf4bbf510c402615b9a179a210aac73eb9
          # +  revision: bf12bb1017ef68f245373df20ce708bebb90bdba
          git = scanner[1]
          if git.match(/github\.com\/(\w+)\/(\w+)/)
            owner = $1
            gem   = $2
          end

          scanner.scan_until(/\n/)
          old = scanner.scan(/^-(.*)/)
          old_ver = old.match(/revision: (\w{40})/)[1]
          scanner.scan_until(/\n/)
          new = scanner.scan(/^\+(.*)/)
          new_ver = new.match(/revision: (\w{40})/)[1]

          gems[gem].merge!({
              owner: owner,
              old_ver: old_ver,
              new_ver: new_ver,
            })
        when scanner.scan(/^\s+specs:/)
          # ignore such block:
          #  GIT
          #    (...)
          #    specs:
          # -    tachikoma (4.0.3.beta)
          # +    tachikoma (4.0.4.beta)
          if scanner.post_match
          end
          scanner.skip_until(/^\+(.*)$/)
        when scanner.scan(/^- (.*)/)
          _, old_gem, old_ver = scanner[0].match(/^-\s+(\S+) \((.*?)\)/).to_a
          unless old_ver.nil?
            gems[old_gem].merge!({
                old_ver: old_ver,
              })
          end
        when scanner.scan(/^\+ (.*)/)
          _, new_gem, new_ver = scanner[0].match(/^\+\s+(\S+) \((.*?)\)/).to_a
          unless new_ver.nil?
            gems[new_gem].merge!({
                new_ver: new_ver,
              })
          end
        else
          scanner.getch
        end
      end
    end
  end
end
