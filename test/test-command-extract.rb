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
      command.execute(templates_dir.join('if1.pm').to_s, %q{[% IF 1}, templates_dir.to_s, '_if.tt')

      assert_equal '[% INCLUDE "_if.tt" %]', templates_dir.join('if1.pm').open.read
      assert_equal %Q{[% IF 1 %]nested[% END %]\n}, templates_dir.join('_if.tt').open.read
    }
  end
end
