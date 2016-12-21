require 'test/unit'
require 'xrt/transaction'
require 'tmpdir'
require 'pathname'

class TestTransaction < Test::Unit::TestCase
  def test_initialize
    Dir.mktmpdir{|dir|
      transaction = XRT::Transaction.new
      assert transaction
      assert_equal({}, transaction.files)
    }
  end

  def test_full_path
    transaction = XRT::Transaction.new
    assert_equal Pathname('/tmp/xrt/a.txt'), transaction.full_path('/tmp/xrt', 'a.txt')
    assert_equal Pathname('/tmp/xrt/somedir/a.txt'), transaction.full_path('/tmp/xrt', 'somedir', 'a.txt')
  end

  def test_new_file_without_conflict
    Dir.mktmpdir{|dir|
      transaction = XRT::Transaction.new
      transaction.new_file transaction.full_path(dir, 'hello.txt').to_s, 'Hello!'
      transaction.commit!
      assert_equal 'Hello!', transaction.full_path(dir, 'hello.txt').open.read
    }
  end

  def test_new_file_with_directory
    Dir.mktmpdir{|dir|
      transaction = XRT::Transaction.new
      transaction.new_file transaction.full_path(dir, 'some_dir/hello.txt').to_s, 'Hello!'
      transaction.commit!
      assert_equal 'Hello!', transaction.full_path(dir, 'some_dir', 'hello.txt').open.read
    }
  end

  def test_new_file_throws_error_when_conflict
    Dir.mktmpdir{|dir|
      Pathname(dir).join('hello.txt').open('w'){ |f| f.write 'existing content' }
      transaction = XRT::Transaction.new

      # when content doesn't match existing content
      assert_raise {
        transaction.new_file transaction.full_path(dir, 'hello.txt').to_s, 'Hello!'
      }

      # when content matches existing content
      assert_nothing_raised {
        transaction.new_file transaction.full_path(dir, 'hello.txt').to_s, 'existing content'
      }
      assert_equal transaction.files, {}, 'nothing added'
    }
  end

  def test_edit_when_editing_existing_file
    Dir.mktmpdir{|dir|
      Pathname(dir).join('hello.txt').open('w'){ |f| f.write 'existing content' }
      transaction = XRT::Transaction.new
      assert_nothing_raised {
        transaction.edit transaction.full_path(dir, 'hello.txt').to_s, 'Hello!'
      }
      assert_equal({
        transaction.full_path(dir, 'hello.txt').to_s => 'Hello!',
      }, transaction.files)
    }
  end

  def test_edit_when_content_is_same
    Dir.mktmpdir{|dir|
      Pathname(dir).join('hello.txt').open('w'){ |f| f.write 'existing content' }
      transaction = XRT::Transaction.new
      assert_nothing_raised {
        transaction.edit transaction.full_path(dir, 'hello.txt').to_s, 'existing content'
      }
      assert_equal({}, transaction.files)
    }
  end

  def test_edit_when_editing_new_file
    Dir.mktmpdir{|dir|
      transaction = XRT::Transaction.new
      assert_raise {
        transaction.edit transaction.full_path(dir, 'hello.txt').to_s, 'Hello!'
      }
      assert_equal({}, transaction.files)
    }
  end

  def _test_add_commit
    Dir.mktmpdir{|dir|
      transaction = XRT::Transaction.new
      transaction.add transaction.full_path(dir, 'hello.txt').to_s, 'Hello!'
      assert_equal({
        transaction.full_path(dir, 'hello.txt').to_s => 'Hello!',
      }, transaction.files)
      assert_equal false, transaction.full_path(dir, 'hello.txt').exist?, 'not exist yet'

      transaction.commit!

      assert_equal true, transaction.full_path(dir, 'hello.txt').exist?, 'now exists'
      assert_equal 'Hello!', transaction.full_path(dir, 'hello.txt').open.read
    }
  end
end
