require 'test/unit'
require 'xrt/transaction'
require 'tmpdir'
require 'pathname'

class TestTransaction < Test::Unit::TestCase
  def test_initialize
    Dir.mktmpdir{|dir|
      transaction = XRT::Transaction.new dir
      assert transaction
      assert transaction.directory
      assert_equal({}, transaction.files)
      assert Pathname(transaction.directory).exist?
    }
  end

  def test_full_path
    transaction = XRT::Transaction.new '/tmp/xrt'
    assert_equal Pathname('/tmp/xrt/a.txt'), transaction.full_path('a.txt')
    assert_equal Pathname('/tmp/xrt/somedir/a.txt'), transaction.full_path('somedir', 'a.txt')
  end

  def test_add_commit
    Dir.mktmpdir{|dir|
      transaction = XRT::Transaction.new dir
      transaction.add 'hello.txt', 'Hello!'
      assert_equal({
        'hello.txt' => 'Hello!',
      }, transaction.files)
      assert_equal false, transaction.full_path('hello.txt').exist?, 'not exist yet'

      transaction.commit!

      assert_equal true, transaction.full_path('hello.txt').exist?, 'now exists'
      assert_equal 'Hello!', transaction.full_path('hello.txt').open.read
    }
  end
end
