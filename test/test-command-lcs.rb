require 'test/unit'
require 'tmpdir'
require 'xrt/command/lcs'

class TestCommandLCS < Test::Unit::TestCase
  def test_annotate
    Dir.mktmpdir{|dir|
      Pathname(dir).join('if1.pm').open('w'){ |f| f.write %q{aaa[% IF 1 %]nested[% END %]bbb} }
      Pathname(dir).join('if2.pm').open('w'){ |f| f.write %q{ccc[% IF 1 %]nested[% END %]ddd} }

      command = XRT::Command::LCS.new
      lcs = command.collect(Pathname(dir).join('if1.pm').to_s, Pathname(dir).join('if2.pm').to_s)
      assert_equal [%q{[% IF 1 %]nested[% END %]}], lcs
    }
  end
end
