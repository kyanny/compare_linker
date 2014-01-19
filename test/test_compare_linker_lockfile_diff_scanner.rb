require_relative "test_helper"

class TestCompareLinkerLockfileDiffScanner < Test::Unit::TestCase
  def test_scan_multi_diffs_in_chunk
    scanner = CompareLinker::LockfileDiffScanner.new(read_fixture_file("multi.diff"))
    scanner.scan

    assert_equal "2.6.3", scanner.gems["octokit"][:old_ver]
    assert_equal "2.7.0", scanner.gems["octokit"][:new_ver]
    assert_equal "~> 0.5.1", scanner.gems["sawyer"][:old_ver]
    assert_equal "~> 0.5.2", scanner.gems["sawyer"][:new_ver]
  end

  def test_skip_no_version_block
  end

  def test_scan_git_revisions
    scanner = CompareLinker::LockfileDiffScanner.new(read_fixture_file("git.diff"))
    scanner.scan

    assert_equal "3cbbfbcf4bbf510c402615b9a179a210aac73eb9", scanner.gems["tachikoma"][:old_ver]
    assert_equal "bf12bb1017ef68f245373df20ce708bebb90bdba", scanner.gems["tachikoma"][:new_ver]
    assert_equal "sanemat",                                  scanner.gems["tachikoma"][:owner]
  end

  def test_skip_specs_block
  end
end
