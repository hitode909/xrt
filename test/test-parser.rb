require 'test/unit'
require 'xrt/parser'

class TestParser < Test::Unit::TestCase
  def setup
    @parser = XRT::Parser.new
  end

  def test_new_statement
    parser = XRT::Parser.new('')

    assert parser.new_statement('hi').kind_of? XRT::Statement::Text
    assert parser.new_statement(' ').kind_of? XRT::Statement::Whitespace
    assert parser.new_statement('[% foo %]').kind_of? XRT::Statement::Directive
    assert parser.new_statement('[% foo IF 1 %]').kind_of? XRT::Statement::Directive
    assert parser.new_statement('[% IF 1 %]').kind_of? XRT::Statement::ControlBlock
    assert parser.new_statement('<').kind_of? XRT::Statement::Tag
    assert parser.new_statement('>').kind_of? XRT::Statement::TagEnd
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

  def test_document_text_and_whitespace_directive
    parser = XRT::Parser.new("1 [% 2 %]\n3")
    doc = parser.document
    assert doc.kind_of? XRT::Statement::Document
    assert_equal [
      XRT::Statement::Text.new('1'),
      XRT::Statement::Whitespace.new(' '),
      XRT::Statement::Directive.new('[% 2 %]'),
      XRT::Statement::Whitespace.new("\n"),
      XRT::Statement::Text.new('3'),
    ], doc.children
  end

  def test_document_block
    parser = XRT::Parser.new('[% IF a %]1[% END %]')
    doc = parser.document
    assert doc.kind_of? XRT::Statement::Document
    if_block = XRT::Statement::ControlBlock.new('[% IF a %]')
    if_block << XRT::Statement::Text.new('1')
    if_block << XRT::Statement::End.new('[% END %]')
    assert_equal [
      if_block
    ], doc.children
  end

  def test_document_nested_block
    parser = XRT::Parser.new('[% IF a %][% IF b %]1[% END %][% END %]')
    doc = parser.document
    assert doc.kind_of? XRT::Statement::Document
    if_block1 = XRT::Statement::ControlBlock.new('[% IF a %]')
    if_block2 = XRT::Statement::ControlBlock.new('[% IF b %]')
    if_block2 << XRT::Statement::Text.new('1')
    if_block2 << XRT::Statement::End.new('[% END %]')
    if_block1 << if_block2
    if_block1 << XRT::Statement::End.new('[% END %]')
    assert_equal [
      if_block1
    ], doc.children
  end

  def test_document_tag
    parser = XRT::Parser.new('<div>a</div>')
    doc = parser.document
    assert doc.kind_of? XRT::Statement::Document

    tag_start = XRT::Statement::Tag.new '<'
    tag_start << XRT::Statement::Text.new('div')
    tag_start << XRT::Statement::TagEnd.new('>')

    text = XRT::Statement::Text.new('a')

    tag_close = XRT::Statement::Tag.new '<'
    tag_close << XRT::Statement::Text.new('/div')
    tag_close << XRT::Statement::TagEnd.new('>')

    tag_pair = XRT::Statement::TagPair.new(tag_start)
    tag_pair << text
    tag_pair << XRT::Statement::TagPairEnd.new(tag_close)
    assert_equal [
      tag_pair,
    ], doc.children
  end

  def test_void_element
    parser = XRT::Parser.new('<img>a')
    doc = parser.document
    assert doc.kind_of? XRT::Statement::Document

    tag = XRT::Statement::Tag.new '<'
    tag << XRT::Statement::Text.new('img')
    tag << XRT::Statement::TagEnd.new('>')

    text = XRT::Statement::Text.new('a')

    assert_equal [
      tag,
      text
    ], doc.children
  end

  def test_block_in_raw_text_element
    parser = XRT::Parser.new('<script>[% IF a %]1[% END %][% b %]</script>')
    doc = parser.document
    assert doc.kind_of? XRT::Statement::Document

    tag_start = XRT::Statement::Tag.new '<'
    tag_start << XRT::Statement::Text.new('script')
    tag_start << XRT::Statement::TagEnd.new('>')

    tag_close = XRT::Statement::Tag.new '<'
    tag_close << XRT::Statement::Text.new('/script')
    tag_close << XRT::Statement::TagEnd.new('>')

    if_block = XRT::Statement::ControlBlock.new('[% IF a %]')
    if_block << XRT::Statement::Text.new('1')
    if_block << XRT::Statement::End.new('[% END %]')

    directive = XRT::Statement::Directive.new('[% b %]')

    tag_pair = XRT::Statement::TagPair.new(tag_start)
    tag_pair << if_block
    tag_pair << directive
    tag_pair << XRT::Statement::TagPairEnd.new(tag_close)

    assert_equal [
      tag_pair,
    ], doc.children
  end

  def test_simple_raw_text_element
    parser = XRT::Parser.new('<script>1<2</script>')
    doc = parser.document
    assert doc.kind_of? XRT::Statement::Document

    tag_start = XRT::Statement::Tag.new '<'
    tag_start << XRT::Statement::Text.new('script')
    tag_start << XRT::Statement::TagEnd.new('>')

    tag_close = XRT::Statement::Tag.new '<'
    tag_close << XRT::Statement::Text.new('/script')
    tag_close << XRT::Statement::TagEnd.new('>')

    tag_pair = XRT::Statement::TagPair.new(tag_start)
    tag_pair << XRT::Statement::Text.new('1')
    tag_pair << XRT::Statement::Text.new('<')
    tag_pair << XRT::Statement::Text.new('2')
    tag_pair << XRT::Statement::TagPairEnd.new(tag_close)

    assert_equal [
      tag_pair,
    ], doc.children
  end

  def test_raw_text_in_block_in_raw_text_element
    parser = XRT::Parser.new('<script>[% IF a %]<[% END %]</script>')
    doc = parser.document
    assert doc.kind_of? XRT::Statement::Document

    tag_start = XRT::Statement::Tag.new '<'
    tag_start << XRT::Statement::Text.new('script')
    tag_start << XRT::Statement::TagEnd.new('>')

    tag_close = XRT::Statement::Tag.new '<'
    tag_close << XRT::Statement::Text.new('/script')
    tag_close << XRT::Statement::TagEnd.new('>')

    if_block = XRT::Statement::ControlBlock.new('[% IF a %]')
    if_block << XRT::Statement::Text.new('<')
    if_block << XRT::Statement::End.new('[% END %]')

    tag_pair = XRT::Statement::TagPair.new(tag_start)
    tag_pair << if_block
    tag_pair << XRT::Statement::TagPairEnd.new(tag_close)

    assert_equal [
      tag_pair,
    ], doc.children
  end

  def test_read_directive
    assert_equal '[% %]', @parser.read_directive('[% %]')
    assert_equal '[% [ ] %]', @parser.read_directive('[% [ ] %]')
    assert_nil @parser.read_directive('hi')
  end

  def test_read_text
    assert_equal '', @parser.read_text('')
    assert_equal 'hi', @parser.read_text('hi')
    assert_equal 'hi[', @parser.read_text('hi[')
    assert_equal 'hi', @parser.read_text('hi[%')
    assert_equal 'hi', @parser.read_text('hi<')
    assert_equal 'hi', @parser.read_text('hi>')
    assert_nil @parser.read_text('[% %]')
  end

  def test_read_tag_start
    assert_equal '<', @parser.read_tag_start('<')
    assert_equal '<', @parser.read_tag_start('<div')
    assert_nil @parser.read_tag_start('hi')
  end

  def test_read_tag_end
    assert_equal '>', @parser.read_tag_end('>')
    assert_equal '>', @parser.read_tag_end('>>')
    assert_nil @parser.read_tag_end('hi')
  end

  def test_split_whitespace
    assert_equal([], @parser.split_whitespace(""))
    assert_equal([" "], @parser.split_whitespace(" "))
    assert_equal(["\n"], @parser.split_whitespace("\n"))
    assert_equal(["hi"], @parser.split_whitespace("hi"))
    assert_equal(["hi there"], @parser.split_whitespace("hi there"))
    assert_equal([" ", "hi", " "], @parser.split_whitespace(" hi "))
    assert_equal([" \n", "hi", "\n "], @parser.split_whitespace(" \nhi\n "))
    assert_equal(["\n", "xxx", "\n"], @parser.split_whitespace("\nxxx\n"))
  end

  def test_tokens
    test_cases = [
      ['<html>', ['<', 'html', '>']],
      ['a [% b %] c', ['a', ' ', '[% b %]', ' ', 'c']],
      ['[% a %] [% b %] [% c %]', ['[% a %]', ' ', '[% b %]', ' ', '[% c %]']],
      ['[% FOR k IN [1, 2, 3] %]', ['[% FOR k IN [1, 2, 3] %]']],
      [
        %q([% WRAPPER "wrapper.tt" WITH args = [1,2,3] %]<div></div>[% END %]),
        [
          %q([% WRAPPER "wrapper.tt" WITH args = [1,2,3] %]),
          *%w(< div > < /div >),
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
