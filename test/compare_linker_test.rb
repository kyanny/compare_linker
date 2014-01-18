require_relative "test_helper"

class TestCompareLinker < Test::Unit::TestCase
  def test_parse_simple
    compare_linker = CompareLinker.new('dummy/dummy', 1)

    chunks = UnifiedDiff.parse(
      read_fixture_file("multi.diff")
    ).chunks

    assert_equal ["octokit", nil, "2.6.3", "2.7.0"], compare_linker.parse(chunks[0])
    assert_equal ["sawyer", nil, "~> 0.5.1", "~> 0.5.2"], compare_linker.parse(chunks[1])
    assert_equal [], compare_linker.parse(chunks[2])
  end

  def test_parse_git
    compare_linker = CompareLinker.new('dummy/dummy', 1)

    chunks = UnifiedDiff.parse(
      read_fixture_file("git.diff")
    ).chunks

    assert_equal ["tachikoma", "sanemat", "3cbbfbcf4bbf510c402615b9a179a210aac73eb9", "bf12bb1017ef68f245373df20ce708bebb90bdba"], compare_linker.parse(chunks[0])
  end
end
