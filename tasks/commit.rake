require 'readline'
require 'open-uri'
require 'rexml/document'
require 'tmpdir'

desc "Run before checking in"
task :pc => ['svn:add', 'svn:delete', 'svn:up', :default, 'svn:st']

desc "Run to check in"
task :commit => :pc do
  if files_to_check_in? && ok_to_check_in?
    command = %[svn ci -m "#{CommitMessage.prompt.to_s}"]
    puts command
    puts %x[#{command}]
  end
end

class CommitMessage < Struct.new(:who, :story, :what)
  def self.prompt
    new retrieve_saved_data("pair"),
        retrieve_saved_data("story"),
        retrieve_saved_data("message")
  end
  
  def to_s
    "#{who}|story #{story}|#{what}"
  end
end

def files_to_check_in?
  %x[svn st --ignore-externals].split("\n").reject {|line| line[0,1] == "X"}.any?
end

def retrieve_saved_data(attribute)
  data_path = File.expand_path(Dir.tmpdir + "/#{attribute}.data")
  `touch #{data_path}` unless File.exist? data_path
  saved_data = File.read(data_path)

  prompt = "#{attribute}"
  prompt << " (previously #{saved_data})" unless saved_data.empty?
  prompt << ": "

  input = Readline.readline(prompt).chomp # The message ultimately committed is chomped anyway.
  while (saved_data.empty? && (input.empty?))
    input = Readline.readline(prompt, true)
  end
  if input.any?
    File.open(data_path, "w") { |file| file << input }
  else
    puts "using: " + saved_data
  end
  input.any? ? input : saved_data
end

def ok_to_check_in?
  return true unless self.class.const_defined?(:CCRB_RSS)
  case build_status
  when :passing
    true
  when :failing
    are_you_sure?("The build is currently broken.") 
  when :cannot_connect
    are_you_sure?("Cannot read cruisecontrol.rb information.")
  end
end

def build_status
  begin
    build_rss = open(CCRB_RSS).read
    doc = REXML::Document.new(build_rss)
    build_title = REXML::XPath.first(doc, '//rss/channel/item/title').text
    return build_title.include?("failed") ? :failing : :passing
  rescue Exception => e
    puts "\n", e.message
    return :cannot_connect
  end
end

def are_you_sure?(message)
  puts "\n", message
  input = ""
  while (input.strip.empty?)
    input = Readline.readline("Are you sure you want to check in? (y/n): ")
  end
  return input.strip.downcase[0,1] == "y"
end
