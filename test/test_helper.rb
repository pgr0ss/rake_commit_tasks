unless defined?(TEST_HELPER_LOADED)
  TEST_HELPER_LOADED = true

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

  MAIN = self
  def MAIN.`(command)
    raise "need to stub: MAIN.`(#{command.inspect})"
  end
  
  def MAIN.system(command)
    raise "need to stub: MAIN.system(#{command.inspect})"
  end
end
