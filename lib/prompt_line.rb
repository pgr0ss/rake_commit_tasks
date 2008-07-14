require 'readline'
require 'tmpdir'

class PromptLine
  
  def initialize(attribute, example)
    @attribute = attribute
    @example = example
  end
  
  def prompt
    input = nil
    loop do
      input = Readline.readline(message).chomp
      break unless (input.empty? && saved_data.empty?)
    end
    
    if input.any?
      save(input)
      return input
    end

    puts "using: #{saved_data}"
    return saved_data
  end  
  
  def message
    previous = saved_data
    hint = previous.empty? ? "for example, #{@example.inspect}" : "previously, #{previous.inspect}"
    "#{@attribute} (#{hint}): "
  end
  
  def save(input)
    File.open(path(@attribute), "w") {|f| f.write(input) }
  end
  
  private
  def saved_data
    @saved_data ||= File.exists?(path(@attribute)) ? File.read(path(@attribute)) : ""
  end
  
  def path(attribute)
    File.expand_path(Dir.tmpdir + "/#{attribute}.data")
  end

end
