require 'readline'
require 'open-uri'
require 'rexml/document'

desc "Run before checking in"
task :pc => ['svn:add', 'svn:delete', 'svn:up', :default, 'svn:st']

desc "Run to check in"
task :commit => :pc do
  if files_to_check_in?
    commit_pair = retrieve_saved_data "pair"
    commit_message = retrieve_saved_data "message"
    command = %[svn ci -m "#{commit_pair.chomp} - #{commit_message.chomp}"]
    puts command
    puts %x[#{command}]
  end
end

def files_to_check_in?
  %x[svn st --ignore-externals].split(/\n/).reject {|line| line[0,1] =~ /X/}.any?
end

def retrieve_saved_data attribute
  data_path = File.expand_path(File.dirname(__FILE__) + "/#{attribute}.data")
  `touch #{data_path}` unless File.exist? data_path
  saved_data = File.read(data_path)

  puts "last #{attribute}: " + saved_data unless saved_data.chomp.empty?

  input = Readline.readline("#{attribute}: ")
  while (saved_data.chomp.empty? && (input.chomp.empty?))
    input = Readline.readline("#{attribute}: ", true)
  end
  if input.chomp.any?
    File.open(data_path, "w") { |file| file << input }
  else
    puts "using: " + saved_data.chomp
  end
  input.chomp.any? ? input : saved_data
end

def ok_to_check_in?
  return true unless broken_build?
  input = Readline.readline("\nThe build is currently broken.  Are you sure you want to check in? (y/n): ")
  return input.downcase[0,1] == "y"
end
