require File.dirname(__FILE__) + "/test_helper"

class SvnRakeTest < Test::Unit::TestCase

  def test_svn_st_displays_svn_status
    MAIN.stubs(:`).with("svn st").returns("output from svn st")
    output = capture_stdout do
      Rake::Task["svn:st"].execute nil
    end
    assert_equal "output from svn st\n", output
  end

  def test_svn_up_displays_output_from_svn
    MAIN.stubs(:`).with("svn up").returns("output from svn up")
    output = capture_stdout do
      Rake::Task["svn:up"].execute nil
    end
    assert_equal "output from svn up\n", output
  end

  def test_svn_up_raises_if_there_are_conflicts
    MAIN.stubs(:`).with("svn up").returns("C      a_conflicted_file\n")
    begin
      capture_stdout do
        Rake::Task["svn:up"].execute nil
      end
    rescue => exception
    end
    assert_not_nil exception
    assert_equal "SVN conflict detected. Please resolve conflicts before proceeding.", exception.message
  end

  def test_svn_add_adds_new_files_and_displays_message
    MAIN.stubs(:`).with("svn st").returns("?      new_file\nM      modified_file\n?      new_file2\n")
    MAIN.expects(:`).with("svn add \"new_file\"")
    MAIN.expects(:`).with("svn add \"new_file2\"")
    output = capture_stdout do
      Rake::Task["svn:add"].execute nil
    end
    assert_equal "added new_file\nadded new_file2\n", output
  end

  def test_svn_add_adds_files_with_special_characters_in_them
    MAIN.stubs(:`).with("svn st").returns("?       leading_space\n?      x\"x\n?      y?y\n?      z'z\n")
    MAIN.expects(:`).with(%Q(svn add "leading_space"))
    MAIN.expects(:`).with(%Q(svn add "x\\\"x"))
    MAIN.expects(:`).with(%Q(svn add "y?y"))
    MAIN.expects(:`).with(%Q(svn add "z'z"))
    capture_stdout do
      Rake::Task["svn:add"].execute nil
    end
  end

  def test_svn_add_does_not_add_svn_conflict_files
    MAIN.expects(:`).never
    MAIN.stubs(:`).with("svn st").returns("?      new_file.r342\n?      new_file.mine")
    output = capture_stdout do
      Rake::Task["svn:add"].execute nil
    end
    assert_equal "", output
  end

  def test_svn_rm_is_an_alias_for_svn_delete
    assert_equal ["svn:delete"], Rake::Task["svn:rm"].prerequisites
  end

  def test_svn_delete_removes_deleted_files_and_displays_message
    MAIN.stubs(:`).with("svn st").returns("!      removed_file\n?      new_file\n!      removed_file2\n")
    MAIN.expects(:`).with("svn up \"removed_file\" && svn rm \"removed_file\"")
    MAIN.expects(:`).with("svn up \"removed_file2\" && svn rm \"removed_file2\"")
    output = capture_stdout do
      Rake::Task["svn:delete"].execute nil
    end
    assert_equal "removed removed_file\nremoved removed_file2\n", output
  end

  def test_svn_revert_all_calls_svn_revert_and_then_removes_all_new_files_and_directories
    MAIN.expects(:system).with('svn revert -R .')
    MAIN.expects(:`).with("svn st").returns("?    some_file.rb\n?    a directory")
    MAIN.expects(:rm_r).with("some_file.rb")
    MAIN.expects(:rm_r).with("a directory")
    capture_stdout do
      Rake::Task["svn:revert_all"].execute nil
    end
  end

end
