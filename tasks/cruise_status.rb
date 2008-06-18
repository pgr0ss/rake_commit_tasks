#!/usr/bin/env ruby -KU
require "rubygems"

begin
  require "hpricot"
  HPRICOT_OK = true
  require "open-uri"
rescue LoadError
  $stderr.puts "WARNING: Run `sudo gem install hpricot` to enable build checking."
  HPRICOT_OK = false
end

class FakeDoc
  def / other
    return []
  end
end

class CruiseStatus
  
  def self.parse_feed( feed_url )
    new open( feed_url )
  rescue Exception => e
    @failures = [e.message]
    new ""
  end
  
  def initialize( project_feed )
    if HPRICOT_OK
      @doc = Hpricot::XML( project_feed )
    else
      @doc = FakeDoc.new
    end
  end
  
  def fail?
    not failures.empty?
  end
  
  def pass?
    not fail?
  end
  
  def failures
    @failures ||= (@doc/"item/title").select { |element|
      element.inner_text =~ /failed$/
    }.map do |element|
      element.inner_text.gsub( /(.*) build \d+ failed$/, '\1' )
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  status = CruiseStatus.parse_feed ARGV.first

  if status.fail?
    puts "FAIL: #{status.failures.join(', ')}"
  else
    puts "OK"
  end
end