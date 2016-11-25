require 'test/unit'
require 'tmpdir'
require 'xrt/command/dump'

class TestParser < Test::Unit::TestCase
  def test_annotate
    Dir.mktmpdir{|dir|
      Pathname(dir).join('if1.pm').open('w'){ |f| f.write %q{[% IF 1 %]nested[% END %]} }

      command = XRT::Command::Dump.new
      source = command.annotate_file Pathname(dir).join('if1.pm')
      assert_equal %q{[% IF 1 %]1nested1[% END %]0}, source
    }
  end

  def test_annotate_broken_template
    Dir.mktmpdir{|dir|
      Pathname(dir).join('if1.pm').open('w'){ |f| f.write %q{[% IF 1 %]nested[% END %} }

      command = XRT::Command::Dump.new
      assert_raise {
        command.annotate_file Pathname(dir).join('if1.pm')
      }
    }
  end
end
