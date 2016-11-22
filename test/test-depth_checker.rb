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

  def test_max_depth
    assert_equal 0, @checker.max_depth(%q{foo})
    assert_equal 0, @checker.max_depth(%q{[% foo %]})
    assert_equal 1, @checker.max_depth(%q{[% IF a %]1[% END %]})

    assert_raises { @checker.max_depth(%q{[% IF a %]}) }
  end
end
