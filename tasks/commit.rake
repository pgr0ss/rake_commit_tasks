require 'rexml/document'

require File.expand_path(File.dirname(__FILE__) + '/../lib/commit_message')
require File.expand_path(File.dirname(__FILE__) + '/../lib/prompt_line')
require File.expand_path(File.dirname(__FILE__) + '/../lib/cruise_status')

def git?
  `git symbolic-ref HEAD`
  $?.success?
end

if git?
  desc "Run to check in"
  task :commit => ['git:reset_soft', 'git:add', 'git:st'] do
    commit_message = CommitMessage.new
    sh_with_output("git config user.name #{commit_message.pair.inspect}")
    message = "#{commit_message.feature} - #{commit_message.message}"
    sh_with_output("git commit -m #{message.inspect}")
    Rake::Task['git:pull_rebase'].invoke
    Rake::Task[:default].invoke
    if ok_to_check_in?
      Rake::Task['git:push'].invoke
    end
  end
else
  desc "Run before checking in"
  task :pc => ['svn:add', 'svn:delete', 'svn:up', :default]

  desc "Run to check in"
  task :commit => "svn:st" do
    if files_to_check_in?
      message = CommitMessage.new.joined_message
      Rake::Task[:pc].invoke

      if ok_to_check_in?
        output = sh_with_output "#{commit_command(message)}"
        revision = output.match(/Committed revision (\d+)\./)[1]
        merge_to_trunk(revision) if `svn info`.include?("branches") && self.class.const_defined?(:PATH_TO_TRUNK_WORKING_COPY)
      end
    else
      puts "Nothing to commit"
    end
  end

  def commit_command(message)
  "svn ci -m #{message.inspect}"
  end

  def files_to_check_in?
  %x[svn st --ignore-externals].split("\n").reject {|line| line[0,1] == "X"}.any?
  end
end

def ok_to_check_in?
  return true unless self.class.const_defined?(:CCRB_RSS)
  cruise_status = CruiseStatus.new(CCRB_RSS)
  cruise_status.pass? ? true : are_you_sure?( "Build FAILURES: #{cruise_status.failures.join(', ')}" )
end

def are_you_sure?(message)
  puts "\n", message
  input = ""
  while (input.strip.empty?)
    input = Readline.readline("Are you sure you want to check in? (y/n): ")
  end
  return input.strip.downcase[0,1] == "y"
end

def sh_with_output(command)
  puts command
  output = `#{command}`
  puts output
  raise unless $?.success?
  output
end
