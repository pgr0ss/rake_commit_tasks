require File.dirname(__FILE__) + "/test_helper"

class SvnRakeTest < Test::Unit::TestCase
  
  test "svn:st displays svn status" do
    MAIN.stubs(:`).with("svn st").returns("output from svn st")
    output = capture_stdout do
      Rake::Task["svn:st"].execute nil
    end
    assert_equal "output from svn st\n", output
  end
  
  test "svn:up displays output from svn" do
    MAIN.stubs(:`).with("svn up").returns("output from svn up")
    output = capture_stdout do
      Rake::Task["svn:up"].execute nil
    end
    assert_equal "output from svn up\n", output
  end
  
  test "svn:up raises if there are conflicts" do
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
  
  test "svn:add adds new files and displays message" do
    MAIN.stubs(:`).with("svn st").returns("?      new_file\nM      modified_file\n?      new_file2\n")
    MAIN.expects(:`).with("svn add \"new_file\"")
    MAIN.expects(:`).with("svn add \"new_file2\"")
    output = capture_stdout do
      Rake::Task["svn:add"].execute nil
    end
    assert_equal "added new_file\nadded new_file2\n", output
  end

  test "svn:add adds files with special characters in them" do
    MAIN.stubs(:`).with("svn st").returns("?       leading_space\n?      x\"x\n?      y?y\n?      z'z\n")
    MAIN.expects(:`).with(%Q(svn add " leading_space"))
    MAIN.expects(:`).with(%Q(svn add "x\\\"x"))
    MAIN.expects(:`).with(%Q(svn add "y?y"))
    MAIN.expects(:`).with(%Q(svn add "z'z"))
    capture_stdout do
      Rake::Task["svn:add"].execute nil
    end
  end
  
  test "svn:add does not add svn conflict files" do
    MAIN.expects(:`).never
    MAIN.stubs(:`).with("svn st").returns("?      new_file.r342\n?      new_file.mine")
    output = capture_stdout do
      Rake::Task["svn:add"].execute nil
    end
    assert_equal "", output
  end
  
  test "svn:rm is an alias for svn:delete" do
    assert_equal ["svn:delete"], Rake::Task["svn:rm"].prerequisites
  end

  test "svn:delete removes deleted files and displays message" do
    MAIN.stubs(:`).with("svn st").returns("!      removed_file\n?      new_file\n!      removed_file2\n")
    MAIN.expects(:`).with("svn up \"removed_file\" && svn rm \"removed_file\"")
    MAIN.expects(:`).with("svn up \"removed_file2\" && svn rm \"removed_file2\"")
    output = capture_stdout do
      Rake::Task["svn:delete"].execute nil
    end
    assert_equal "removed removed_file\nremoved removed_file2\n", output
  end
  
  test "svn:revert_all calls svn revert and then removes all new files and directories" do
    MAIN.expects(:system).with('svn revert -R .')
    MAIN.expects(:`).with("svn st").returns("?    some_file.rb\n?    a directory")
    MAIN.expects(:rm_r).with("some_file.rb")
    MAIN.expects(:rm_r).with("a directory")
    capture_stdout do
      Rake::Task["svn:revert_all"].execute nil
    end
  end
  
end
