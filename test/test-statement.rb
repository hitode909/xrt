require 'test/unit'
require 'xrt/statement'

class TestStatement < Test::Unit::TestCase
  def test_text
    text = XRT::Statement::Text.new('hi')
    assert text.kind_of? XRT::Statement
    assert_equal text.content, 'hi'
  end

  def test_directive
    text = XRT::Statement::End.new('[% foo() %]')
    assert text.kind_of? XRT::Statement
    assert_equal text.content, '[% foo() %]'
  end

  def test_end
    text = XRT::Statement::End.new('[% END %]')
    assert text.kind_of? XRT::Statement
    assert_equal text.content, '[% END %]'
  end

  def test_block
    text = XRT::Statement::Block.new('[% IF 1 %]')
    assert text.kind_of? XRT::Statement
    assert_equal text.content, '[% IF 1 %]'
    assert_equal text.children, []
  end

  def test_document
    document = XRT::Statement::Document.new
    s1 = XRT::Statement::Text.new('ok')
    s2 = XRT::Statement::Directive.new('[% foo %]')
    document << s1
    document << s2

    assert_equal document.children, [s1, s2]

    assert_equal document.content, %q{ok[% foo %]}
  end
end

class TestBlock < Test::Unit::TestCase
  def test_push_child
    block = XRT::Statement::Block.new('[% IF 1 %]')
    assert_equal false, block.closed?

    statement_ok = XRT::Statement::Text.new('ok')
    statement_end = XRT::Statement::End.new('[% END %]')

    block << statement_ok
    assert_equal false, block.closed?

    block << statement_end
    assert_equal true, block.closed?

    assert_equal block.children, [statement_ok, statement_end]

    assert_raises {
      block << statement_ok
    }
  end

  def test_content
    block = XRT::Statement::Block.new('[% IF 1 %]')
    block << XRT::Statement::Text.new('ok')
    block << XRT::Statement::End.new('[% END %]')

    assert_equal block.content, %q{[% IF 1 %]ok[% END %]}
  end
end
