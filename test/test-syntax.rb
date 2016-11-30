require 'test/unit'
require 'xrt/syntax'

class TestSyntax < Test::Unit::TestCase
  def setup
    @syntax = XRT::Syntax.new
  end

  def test_remove_comment
    assert_equal 'foo', @syntax.remove_comment('foo # bar')
  end

  def test_whitespace?
    assert @syntax.whitespace? ''
    assert @syntax.whitespace? ' '
    assert @syntax.whitespace? " \n"
    assert_nil @syntax.whitespace? 'a'
  end

  def test_beginning_block?
    assert @syntax.beginning_block? '[% IF 1 %]'
    assert @syntax.beginning_block? '[% if 1 %]'
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
    assert @syntax.end_block? '[% end %]'
    assert @syntax.end_block? '[% END # WRAPPER "wrapper.tt" WITH %]'
    assert_nil @syntax.end_block? ' END '
  end

  def test_block_level
    assert_equal(0, @syntax.block_level('[% foo %]'))
    assert_equal(1, @syntax.block_level('[% IF 1 %]'))
    assert_equal(1, @syntax.block_level('[%- IF 1 -%]'))
    assert_equal(0, @syntax.block_level('[% IF a THEN 1 END %]'))
    assert_equal(0, @syntax.block_level('[% IF a THEN 1 ELSE 0 END %]'))
    assert_equal(0, @syntax.block_level('[% a ? 1 : 0 %]'))
    assert_equal(-1, @syntax.block_level('[% END # WRAPPER "wrapper.tt" WITH %]'))
    assert_equal(0, @syntax.block_level('[% 2 UNLESS a %]'))
    assert_equal(0, @syntax.block_level('[% 1 IF a %]'))
  end
end
