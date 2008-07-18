require File.dirname(__FILE__) + "/test_helper"

class CommitRakeTest < Test::Unit::TestCase
  
  test "double-book rake pc" do
    expected = %w[svn:add svn:delete svn:up default]
    assert_equal expected, Rake::Task["pc"].prerequisites
  end
  
  test "commit does nothing if no files to check in" do
    MAIN.stubs(:`).returns("")
    Rake::Task.stubs(:[]).returns(stub_everything)
    output = capture_stdout do
      Rake::Task["commit"].execute nil
    end
    assert_equal "", output
  end

  test "commit ignores svn externals when checking for files to check in" do
    MAIN.stubs(:`).with("svn st --ignore-externals").returns("X      an_external\n")
    Rake::Task.stubs(:[]).returns(stub_everything)
    output = capture_stdout do
      Rake::Task["commit"].execute nil
    end
    assert_equal "", output
  end
  
  test "commit_command uses the message in an svn ci" do
    assert_equal %Q{svn ci -m "some message"}, commit_command("some message")
  end
  
  test "commit_command escapes all quotes" do
    assert_equal %Q{svn ci -m "single ' and double \\""}, commit_command(%Q{single ' and double "})
  end
  
end
