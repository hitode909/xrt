require 'test/unit'
require 'xrt/parser'

class TestParser < Test::Unit::TestCase
  def setup
    @parser = XRT::Parser.new
  end

  def test_document_empty
    parser = XRT::Parser.new('')
    doc = parser.document
    assert doc.kind_of? XRT::Statement::Document
    assert_equal [], doc.children
  end

  def test_document_text_directive
    parser = XRT::Parser.new('1[% 2 %]3')
    doc = parser.document
    assert doc.kind_of? XRT::Statement::Document
    assert_equal [
      XRT::Statement::Text.new('1'),
      XRT::Statement::Directive.new('[% 2 %]'),
      XRT::Statement::Text.new('3'),
    ], doc.children
  end

  def test_document_block
    parser = XRT::Parser.new('[% IF a %]1[% END %]')
    doc = parser.document
    assert doc.kind_of? XRT::Statement::Document
    if_block = XRT::Statement::Block.new('[% IF a %]')
    if_block << XRT::Statement::Text.new('1')
    if_block << XRT::Statement::Text.new('[% END %]')
    assert_equal [
      if_block
    ], doc.children
  end

    def test_document_nested_block
      parser = XRT::Parser.new('[% IF a %][% IF b %]1[% END %][% END %]')
      doc = parser.document
      assert doc.kind_of? XRT::Statement::Document
      if_block1 = XRT::Statement::Block.new('[% IF a %]')
      if_block2 = XRT::Statement::Block.new('[% IF b %]')
      if_block2 << XRT::Statement::Text.new('1')
      if_block2 << XRT::Statement::Text.new('[% END %]')
      if_block1 << if_block2
      if_block1 << XRT::Statement::Text.new('[% END %]')
      assert_equal [
        if_block1
      ], doc.children
    end

  def test_read_directive
    assert_equal '[% %]', @parser.read_directive('[% %]')
    assert_equal '[% [ ] %]', @parser.read_directive('[% [ ] %]')
    assert_nil @parser.read_directive('hi')
  end

  def test_read_text
    assert_equal 'hi', @parser.read_text('hi')
    assert_equal 'hi[', @parser.read_text('hi[')
    assert_equal 'hi', @parser.read_text('hi[%')
    assert_nil @parser.read_text('[% %]')
  end

  def test_tokens
    test_cases = [
      ['<html>', ['<html>']],
      ['a [% b %] c', ['a ', '[% b %]', ' c']],
      ['[% a %] [% b %] [% c %]', ['[% a %]', ' ', '[% b %]', ' ', '[% c %]']],
      ['[% FOR k IN [1, 2, 3] %]', ['[% FOR k IN [1, 2, 3] %]']],
      [
        %q([% WRAPPER "wrapper.tt" WITH args = [1,2,3] %]<div></div>[% END %]),
        [
          %q([% WRAPPER "wrapper.tt" WITH args = [1,2,3] %]),
          %q(<div></div>),
          %q([% END %]),
        ]
      ],
    ]

    test_cases.each{|test_case|
      input, expected = *test_case
      parser = XRT::Parser.new(input)
      assert_equal expected, parser.tokens
    }
  end
end
