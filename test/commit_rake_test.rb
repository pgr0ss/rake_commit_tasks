require File.dirname(__FILE__) + "/test_helper"

class CommitRakeTest < Test::Unit::TestCase
  
  test "double-book rake pc" do
    expected = %w[svn:add svn:delete svn:up default svn:st]
    assert_equal expected, Rake::Task["pc"].prerequisites
  end
  
  test "commit does nothing if no files to check in" do
    MAIN.stubs(:`).returns("")
    output = capture_stdout do
      Rake::Task["commit"].execute nil
    end
    assert_equal "", output
  end

  test "commit ignores svn externals when checking for files to check in" do
    MAIN.stubs(:`).with("svn st --ignore-externals").returns("X      an_external\n")
    output = capture_stdout do
      Rake::Task["commit"].execute nil
    end
    assert_equal "", output
  end
  
  test "commit prompts for pair and message" do
    MAIN.stubs(:`).with("svn st --ignore-externals").returns("A      a_new_file\n")
    output = capture_stdout do
      Rake::Task["commit"].execute nil
    end
    assert_equal "", output
  end
  
end
