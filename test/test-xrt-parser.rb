require 'test/unit'
require 'xrt/parser'

class TestXRTParser < Test::Unit::TestCase
  def setup
    @parser = XRT::Parser.new
  end

  def test_statements
    test_cases = [
      ['<html>', ['<html>']],
      ['a [% b %] c', ['a ', '[% b %]', ' c']],
      ['[% FOR k IN [1, 2, 3] %]', ['[% FOR k IN [1, 2, 3] %]']],
    ]

    test_cases.each{|test_case|
      input, expected = *test_case
      parser = XRT::Parser.new(input)
      assert_equal expected, parser.statements
    }
  end
end
