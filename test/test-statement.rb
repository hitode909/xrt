require 'test/unit'
require 'xrt/statement'

class TestStatementFactory < Test::Unit::TestCase
  def test_new_from_string
    assert XRT::Statement::Factory.new_from_content('hi').kind_of? XRT::Statement::Text
    assert XRT::Statement::Factory.new_from_content(' ').kind_of? XRT::Statement::Whitespace
    assert XRT::Statement::Factory.new_from_content('[% foo %]').kind_of? XRT::Statement::Directive
    assert XRT::Statement::Factory.new_from_content('[% foo IF 1 %]').kind_of? XRT::Statement::Directive
    assert XRT::Statement::Factory.new_from_content('[% IF 1 %]').kind_of? XRT::Statement::Block
    assert XRT::Statement::Factory.new_from_content('<').kind_of? XRT::Statement::Tag
    assert XRT::Statement::Factory.new_from_content('>').kind_of? XRT::Statement::TagEnd
  end
end

class TestStatement < Test::Unit::TestCase
  def test_text
    text = XRT::Statement::Text.new('hi')
    assert text.kind_of? XRT::Statement
    assert_equal text.content, 'hi'
    assert_equal text.children, []
  end

  def test_text_auto_indent
    text = XRT::Statement::Text.new(<<'HTML')
<html>
    <body>

    </body>
  </html>
HTML

    assert_equal text.auto_indent, <<'HTML'
<html>
  <body>

  </body>
</html>
HTML
  end

  def test_directive
    text = XRT::Statement::End.new('[% foo() %]')
    assert text.kind_of? XRT::Statement
    assert_equal text.content, '[% foo() %]'
    assert_equal text.children, []
  end

  def test_tag_start
    tag_start = XRT::Statement::TagStart.new('<')
    assert tag_start.kind_of? XRT::Statement
    assert_equal tag_start.content, '<'
    assert_equal tag_start.children, []
  end

  def test_tag_end
    tag_end = XRT::Statement::TagEnd.new('<')
    assert tag_end.kind_of? XRT::Statement::End
    assert_equal tag_end.content, '<'
    assert_equal tag_end.children, []
  end

  def test_tag
    tag = XRT::Statement::Tag.new('<')
    assert tag.kind_of? XRT::Statement::Tag
    assert_equal tag.children, [
      XRT::Statement::TagStart.new('<')
    ]
    assert_false tag.closed?
    tag << XRT::Statement::TagEnd.new('>')
    assert tag.closed?
  end

  def test_tag_contains_directive?
    tag = XRT::Statement::Tag.new('<')
    assert_false tag.contains_directive?

    tag << XRT::Statement::Text.new('div')
    assert_false tag.contains_directive?

    tag << XRT::Statement::Directive.new('[% foo %]')
    assert tag.contains_directive?
  end


  def test_end
    text = XRT::Statement::End.new('[% END %]')
    assert text.kind_of? XRT::Statement
    assert_equal text.content, '[% END %]'
    assert_equal text.children, []
  end

  def test_block
    block = XRT::Statement::Block.new('[% IF 1 %]')
    assert block.kind_of? XRT::Statement
    assert_equal block.children, [
      XRT::Statement::Directive.new('[% IF 1 %]')
    ]
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

  def test_replace_child
    document = XRT::Statement::Document.new
    s1 = XRT::Statement::Text.new('1')
    s2 = XRT::Statement::Text.new('2')
    s3 = XRT::Statement::Text.new('3')
    document << s1

    assert_nil document.replace_child(s2, s3),'when not found'
    assert_equal '1', document.content, 'not changed'

    replaced = document.replace_child(s2, s1)
    assert_same replaced, s1
    assert_equal '2', document.content, 'replaced'
  end

  def test_replace_child_for_descendant
    document = XRT::Statement::Document.new
    if_block = XRT::Statement::Block.new('[% IF a %]')
    if_block_inner_text = XRT::Statement::Text.new('1')
    new_if_block_inner_text = XRT::Statement::Text.new('2')
    if_block << if_block_inner_text
    if_block << XRT::Statement::Text.new('[% END %]')
    document << if_block

    assert document.replace_child(new_if_block_inner_text, if_block_inner_text)
    assert_equal '[% IF a %]2[% END %]', document.content
  end

  def test_depth
    document = XRT::Statement::Document.new
    s1 = XRT::Statement::Text.new('1')
    if_block = XRT::Statement::Block.new('[% IF a %]')
    if_block_inner_text = XRT::Statement::Text.new('1')
    if_block << if_block_inner_text
    if_block << XRT::Statement::Text.new('[% END %]')
    not_child = XRT::Statement::Text.new('not_child')
    document << s1
    document << if_block

    assert_equal 0, document.depth(s1)
    assert_equal 0, document.depth(if_block)
    assert_equal 1, document.depth(if_block_inner_text)
    assert_equal nil, document.depth(not_child)
  end

  def test_statements
    document = XRT::Statement::Document.new
    assert_equal [], document.find_blocks, 'when there is no block'

    text_block = XRT::Statement::Text.new('1')
    document << text_block
    if_block = XRT::Statement::Block.new('[% IF a %]')
    document << if_block
    if_directive = XRT::Statement::Directive.new('[% IF a %]')

    assert_equal [ text_block, if_block, if_directive ], document.statements, 'returns statements'
  end

  def test_find_blocks
    document = XRT::Statement::Document.new
    assert_equal [], document.find_blocks, 'when there is no block'

    document << XRT::Statement::Text.new('1')
    if_block = XRT::Statement::Block.new('[% IF a %]')
    document << if_block

    assert_equal [ if_block ], document.find_blocks, 'returns block'
  end
end

class TestBlock < Test::Unit::TestCase
  def test_push_child
    block = XRT::Statement::Block.new('[% IF 1 %]')
    assert_equal false, block.closed?

    statement_if = XRT::Statement::Directive.new('[% IF 1 %]')
    statement_ok = XRT::Statement::Text.new('ok')
    statement_end = XRT::Statement::End.new('[% END %]')

    block << statement_ok
    assert_equal false, block.closed?

    block << statement_end
    assert_equal true, block.closed?

    assert_equal block.children, [statement_if, statement_ok, statement_end]

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

class TestTag < Test::Unit::TestCase
  def test_opening_tag
    tag = XRT::Statement::Tag.new('<')
    tag << XRT::Statement::Text.new('div')
    tag << XRT::Statement::TagEnd.new('>')
    assert tag.tag_opening?
    assert_false tag.tag_closing?
  end

  def test_closing_tag
    tag = XRT::Statement::Tag.new('<')
    tag << XRT::Statement::Text.new('/div')
    tag << XRT::Statement::TagEnd.new('>')
    assert_false tag.tag_opening?
    assert tag.tag_closing?
  end

  def test_independent_tag
    tag = XRT::Statement::Tag.new('<')
    tag << XRT::Statement::Text.new('div/')
    tag << XRT::Statement::TagEnd.new('>')
    assert_false tag.tag_opening?
    assert_false tag.tag_closing?
    assert tag.tag_independent?
  end

end
