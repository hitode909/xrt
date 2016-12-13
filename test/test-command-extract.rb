require 'test/unit'
require 'tmpdir'
require 'xrt/command/extract'

class TestCommandExtract < Test::Unit::TestCase
  def test_extract
    Dir.mktmpdir{|dir|
      templates_dir = Pathname(dir).join('templates')
      templates_dir.mkdir
      templates_dir.join('if1.pm').open('w'){ |f| f.write %q{[% IF 1 %]nested[% END %]} }

      command = XRT::Command::Extract.new
      command.execute(templates_dir.join('if1.pm').to_s, %q{[% IF 1 %]}, templates_dir.to_s, '_if.tt')

      assert_equal '[% INCLUDE "_if.tt" %]', templates_dir.join('if1.pm').open.read
      assert_equal %Q{[% IF 1 %]nested[% END %]\n}, templates_dir.join('_if.tt').open.read
    }
  end

  def test_as_transaction
    Dir.mktmpdir{|dir|
      templates_dir = Pathname(dir).join('templates')
      templates_dir.mkdir
      templates_dir.join('if1.pm').open('w'){ |f| f.write %q{[% IF 1 %]nested[% END %]} }

      command = XRT::Command::Extract.new
      transaction = command.as_transaction(templates_dir.join('if1.pm').to_s, %q{[% IF 1 %]}, templates_dir.to_s, '_if.tt')
      assert_equal({
        templates_dir.join('if1.pm').to_s => '[% INCLUDE "_if.tt" %]',
        templates_dir.join('_if.tt').to_s => %Q{[% IF 1 %]nested[% END %]\n},
      }, transaction.files)
    }
  end

  def _todo_est_extract_text
    Dir.mktmpdir{|dir|
      templates_dir = Pathname(dir).join('templates')
      templates_dir.mkdir
      templates_dir.join('a.html').open('w'){ |f| f.write <<'HTML' }
<html>
  [% a %]
  <h1>
    hi
  </h1>
  [% b %]
</html>
HTML

      command = XRT::Command::Extract.new
      transaction = command.as_transaction(templates_dir.join('a.html').to_s, %q{<h1>}, templates_dir.to_s, '_h1.tt')
      assert_equal({
        templates_dir.join('a.html').to_s => <<'HTML',
<html>
  [% a %]
  [% INCLUDE "_h1.tt" %]
  [% b %]
</html>
HTML

        templates_dir.join('_h1.tt').to_s => <<'HTML',
<h1>
  hi
</h1>
HTML

      }, transaction.files)
    }
  end
end
