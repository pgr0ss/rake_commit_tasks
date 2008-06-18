require File.expand_path(File.dirname(__FILE__) + "/test_helper")
require File.expand_path(File.dirname(__FILE__) + "/../tasks/cruise_status")

FAIL_RESPONSE = <<-EOS
<rss version="2.0">
  <channel>
    <title>CruiseControl RSS feed</title>
    <link>http://localhost:3333/</link>
    <description>CruiseControl projects and their build statuses</description>
    <language>en-us</language>
    <ttl>10</ttl>
    <item>
      <title>failed build 1126 failed</title>
      <description>stuff</description>
      <pubDate>Tue, 17 Jun 2008 22:12:46 Z</pubDate>
      <guid>http://localhost:3333/builds/failed/1126</guid>
      <link>http://localhost:3333/builds/failed/1126</link>
    </item>
    <item>
      <title>passed build 1126 success</title>
      <description>stuff</description>
      <pubDate>Tue, 17 Jun 2008 22:12:46 Z</pubDate>
      <guid>http://localhost:3333/builds/passed/1126</guid>
      <link>http://localhost:3333/builds/passed/1126</link>
    </item>
  </channel>
</rss>
EOS

PASS_RESPONSE = <<-EOS
<rss version="2.0">
  <channel>
    <title>CruiseControl RSS feed</title>
    <link>http://localhost:3333/</link>
    <description>CruiseControl projects and their build statuses</description>
    <language>en-us</language>
    <ttl>10</ttl>
    <item>
      <title>passed build 1127 success</title>
      <description>stuff</description>
      <pubDate>Tue, 17 Jun 2008 22:12:46 Z</pubDate>
      <guid>http://localhost:3333/builds/passed/1127</guid>
      <link>http://localhost:3333/builds/passed/1127</link>
    </item>
    <item>
      <title>passed build 1126 success</title>
      <description>stuff</description>
      <pubDate>Tue, 17 Jun 2008 22:12:46 Z</pubDate>
      <guid>http://localhost:3333/builds/passed/1126</guid>
      <link>http://localhost:3333/builds/passed/1126</link>
    </item>
  </channel>
</rss>
EOS

class TestCruiseStatusFail < Test::Unit::TestCase
  
  def setup
    CruiseStatus.any_instance.expects(:open).with('ccrb.rss').returns(stub(:read => FAIL_RESPONSE))
    @cruise_checker = CruiseStatus.new 'ccrb.rss'
  end
  
  def test_failed_projects_are_parsed_correctly
    assert_equal %w{failed}, @cruise_checker.failures
  end
  
  def test_fail_is_true_when_cruise_is_failed
    assert_equal true, @cruise_checker.fail?
  end
  
  def test_pass_is_false_when_cruise_is_failed
    assert_equal false, @cruise_checker.pass?
  end
end

class TestCruiseStatusPass < Test::Unit::TestCase
  
  def setup
    CruiseStatus.any_instance.expects(:open).with('ccrb.rss').returns(stub(:read => PASS_RESPONSE))
    @cruise_checker = CruiseStatus.new 'ccrb.rss'
  end
  
  def test_passing_projects_are_parsed_correctly
    assert_equal [], @cruise_checker.failures
  end
  
  def test_fail_is_false_when_cruise_is_passing
    assert_equal false, @cruise_checker.fail?
  end
  
  def test_pass_is_true_when_cruise_is_passing
    assert_equal true, @cruise_checker.pass?
  end
end

class TestCruiseStatusCannotConnect < Test::Unit::TestCase

  def test_fail_is_true_when_cannot_connect_to_cruise
    CruiseStatus.any_instance.expects(:open).with('bad_url').raises(Exception, 'Cannot connect')
    assert_equal true, CruiseStatus.new('bad_url').fail?
  end

  def test_pass_is_false_when_cannot_connect_to_cruise
    CruiseStatus.any_instance.expects(:open).with('bad_url').raises(Exception, 'Cannot connect')
    assert_equal false, CruiseStatus.new('bad_url').pass?
  end
end