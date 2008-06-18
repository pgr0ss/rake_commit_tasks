require 'readline'
require 'open-uri'
require 'rexml/document'
require 'tmpdir'

require File.expand_path(File.dirname(__FILE__) + '/commit_message')
require File.expand_path(File.dirname(__FILE__) + '/cruise_status')

desc "Run before checking in"
task :pc => ['svn:add', 'svn:delete', 'svn:up', :default, 'svn:st']

desc "Run to check in"
task :commit => [:pc, :ci]

desc "Check in code, prompting for metadata"
task :ci do
  if files_to_check_in? && ok_to_check_in?
    puts %x[svn st --ignore-externals]
    command = %[svn ci -m "#{CommitMessage.prompt.to_s}"]
    puts command
    puts %x[#{command}]
  end
end

def files_to_check_in?
  %x[svn st --ignore-externals].split("\n").reject {|line| line[0,1] == "X"}.any?
end

def retrieve_saved_data(attribute, for_example)
  data_path = File.expand_path(Dir.tmpdir + "/#{attribute}.data")
  `touch #{data_path}` unless File.exist? data_path
  saved_data = File.read(data_path)

  prompt = "#{attribute}"
  if saved_data.empty?
    prompt << " (for example, '#{for_example}')"
  else
    prompt << " (previously '#{saved_data}')"
  end
  prompt << ": "

  input = Readline.readline(prompt).chomp
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

  build_status.pass? ? true : are_you_sure?( "Build FAILURES: #{build_status.failures.join(', ')}" )
end

def build_status
  CruiseStatus.parse_feed CCRB_RSS
rescue Exception => e
  puts "\n", e.message
  return nil
end

def are_you_sure?(message)
  puts "\n", message
  input = ""
  while (input.strip.empty?)
    input = Readline.readline("Are you sure you want to check in? (y/n): ")
  end
  return input.strip.downcase[0,1] == "y"
end