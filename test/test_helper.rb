$: << File.expand_path(File.join(__dir__, "..", "lib"))
require "compare_linker"
require "compare_linker/lockfile_diff_scanner"
require "compare_linker/webhook_payload"
require "compare_linker/rack_app"
require "test/unit"

def read_fixture_file(filename)
  File.read(File.expand_path(File.join(__dir__, "fixtures", filename)))
end
