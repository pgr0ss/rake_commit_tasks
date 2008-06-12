require "rubygems"

require "rake"
Dir.glob(File.dirname(__FILE__) + "/../tasks/**/*.rake").each { |rakefile| load rakefile }

require "test/unit"
gem "dust"; require "dust"
gem "mocha"; require "mocha"

Test::Unit::TestCase.class_eval do
  def capture_stdout(&block)
    old_stdout, $stdout = $stdout, StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = old_stdout
  end
end

module Kernel
  def self.`(command)
    raise "need to stub: Kernel.`(#{command.inspect})"
  end
  
  def backtick_with_hook(command)
    Kernel.send :`, command
  end
  
  alias_method :backtick_without_hook, :`
  alias_method :`, :backtick_with_hook
end
