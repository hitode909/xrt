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

  def test_new_file_without_conflict
    Dir.mktmpdir{|dir|
      transaction = XRT::Transaction.new dir
      transaction.new_file 'hello.txt', 'Hello!'
      transaction.commit!
      assert_equal 'Hello!', transaction.full_path('hello.txt').open.read
    }
  end

  def test_new_file_throws_error_when_conflict
    Dir.mktmpdir{|dir|
      Pathname(dir).join('hello.txt').open('w'){ |f| f.write 'existing content' }
      transaction = XRT::Transaction.new dir

      # when content doesn't match existing content
      assert_raise {
        transaction.new_file 'hello.txt', 'Hello!'
      }

      # when content matches existing content
      assert_nothing_raised {
        transaction.new_file 'hello.txt', 'existing content'
      }
      assert_equal transaction.files, {}, 'nothing added'
    }
  end

  def test_edit_when_editing_existing_file
    Dir.mktmpdir{|dir|
      Pathname(dir).join('hello.txt').open('w'){ |f| f.write 'existing content' }
      transaction = XRT::Transaction.new dir
      assert_nothing_raised {
        transaction.edit 'hello.txt', 'Hello!'
      }
      assert_equal({
        'hello.txt' => 'Hello!',
      }, transaction.files)
    }
  end

  def test_edit_when_content_is_same
    Dir.mktmpdir{|dir|
      Pathname(dir).join('hello.txt').open('w'){ |f| f.write 'existing content' }
      transaction = XRT::Transaction.new dir
      assert_nothing_raised {
        transaction.edit 'hello.txt', 'existing content'
      }
      assert_equal({}, transaction.files)
    }
  end

  def test_edit_when_editing_new_file
    Dir.mktmpdir{|dir|
      transaction = XRT::Transaction.new dir
      assert_raise {
        transaction.edit 'hello.txt', 'Hello!'
      }
      assert_equal({}, transaction.files)
    }
  end

  def _test_add_commit
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
