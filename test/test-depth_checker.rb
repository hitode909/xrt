require 'test/unit'
require 'xrt/depth_checker'

class TestDepthChecker < Test::Unit::TestCase
  def setup
    @checker = XRT::DepthChecker.new
  end

  def test_check
    assert_equal true, @checker.check(%q{[% IF a %]1[% END %]})[0]
    assert_equal true, @checker.check(%q{hi})[0]
    assert_equal false, @checker.check(%q{[% IF a %]})[0]

    assert_equal true, @checker.check(%q{[% IF a %]1[% END %]})[1].kind_of?(String)
    assert_equal true, @checker.check(%q{[% IF a %]})[1].kind_of?(String)
  end
end
