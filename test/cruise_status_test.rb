require File.dirname(__FILE__) + "/test_helper"

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

FAIL_RESPONSE_ON_POINT_REVISION = <<-EOS
<rss version="2.0">
  <channel>
    <title>CruiseControl RSS feed</title>
    <link>http://localhost:3333/</link>
    <description>CruiseControl projects and their build statuses</description>
    <language>en-us</language>
    <ttl>10</ttl>
    <item>
      <title>my_project build 1126.1 failed</title>
      <description>stuff</description>
      <pubDate>Tue, 17 Jun 2008 22:12:46 Z</pubDate>
      <guid>http://localhost:3333/builds/failed/1126</guid>
      <link>http://localhost:3333/builds/failed/1126</link>
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
  
  test "failed projects are parsed correctly" do
    assert_equal %w{failed}, @cruise_checker.failures
  end
    
  test "pass is false when cruise is failed" do
    assert_equal false, @cruise_checker.pass?
  end
end

class TestCruiseStatusFailOnPointRevision < Test::Unit::TestCase
  
  def setup
    CruiseStatus.any_instance.expects(:open).with('ccrb.rss').returns(stub(:read => FAIL_RESPONSE_ON_POINT_REVISION))
    @cruise_checker = CruiseStatus.new 'ccrb.rss'
  end

  test "failed projects are parsed correctly with point revisions" do
    assert_equal %w{my_project}, @cruise_checker.failures
  end
end

class TestCruiseStatusPass < Test::Unit::TestCase
  
  def setup
    CruiseStatus.any_instance.expects(:open).with('ccrb.rss').returns(stub(:read => PASS_RESPONSE))
    @cruise_checker = CruiseStatus.new 'ccrb.rss'
  end
  
  test "passing projects are parsed correctly" do
    assert_equal [], @cruise_checker.failures
  end
  
  test "test pass is true when cruise is passing" do
    assert_equal true, @cruise_checker.pass?
  end
end

class TestCruiseStatusCannotConnect < Test::Unit::TestCase

  test "pass is false when cannot connect to cruise" do
    CruiseStatus.any_instance.expects(:open).with('bad_url').raises(Exception, 'Cannot connect')
    assert_equal false, CruiseStatus.new('bad_url').pass?
  end
end
