require 'test/unit'
require 'xrt/parser'

class TestXRTParser < Test::Unit::TestCase
  def setup
    @parser = XRT::Parser.new
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
