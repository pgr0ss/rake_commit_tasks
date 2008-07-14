require File.dirname(__FILE__) + "/test_helper"

class PromptLineTest < Test::Unit::TestCase

  test "message uses example if saved attribute does not exist" do
    File.expects(:exists?).with(Dir.tmpdir + "/pair.data").returns(false)
    assert_equal 'pair (for example, "bg/pg"): ', PromptLine.new("pair", "bg/pg").message
  end
  
  test "message uses saved attribute if exists" do
    File.expects(:exists?).with(Dir.tmpdir + "/pair.data").returns(true)
    File.expects(:read).with(Dir.tmpdir + "/pair.data").returns("John Doe")
    assert_equal 'pair (previously, "John Doe"): ', PromptLine.new("pair", "bg/pg").message
  end
  
  test "save will save entered value to disk" do
    File.expects(:open).with(Dir.tmpdir + "/feature.data", "w").yields(file = mock)
    file.expects(:write).with("card 100")
    PromptLine.new("feature", "").save("card 100")
  end
  
end
