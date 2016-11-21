require 'test/unit'
require 'xrt/syntax'

class TC_XRT_Syntax < Test::Unit::TestCase
  def setup
    @syntax = XRT::Syntax.new
  end

  def test_remove_comment
    assert_equal 'foo', @syntax.remove_comment('foo # bar')
  end

  def test_beginning_block?
    assert @syntax.beginning_block? '[% IF 1 %]'
    assert @syntax.beginning_block? '[% WHILE 1 %]'
    assert_nil @syntax.beginning_block? '[% END # WRAPPER "wrapper.tt" WITH %]'
    assert_nil @syntax.beginning_block? '[% "true" UNLESS false %]'
  end

  def test_block?
    assert @syntax.beginning_block? '[% IF 1 %]'
    assert @syntax.beginning_block? '[%- IF 1 -%]'
    assert @syntax.beginning_block? "[% IF 1\nfoo\nEND %]"
    assert_nil @syntax.beginning_block? "hi"
    assert_nil @syntax.beginning_block? "[%"
  end

  def test_end_block?
    assert @syntax.end_block? '[% END %]'
    assert @syntax.end_block? '[% END # WRAPPER "wrapper.tt" WITH %]'
    assert_nil @syntax.end_block? ' END '
  end

  def test_block_level
    assert_equal(-1, @syntax.block_level('[% END # WRAPPER "wrapper.tt" WITH %]'))
    assert_equal(0, @syntax.block_level('[% "true" UNLESS false %]'))
  end
end
