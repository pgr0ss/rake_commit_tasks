class CommitMessage < Struct.new(:who, :id, :what)
  def self.prompt
    new retrieve_saved_data("pair", "bg/pg"),
        retrieve_saved_data("feature", "story 83"),
        retrieve_saved_data("message", "Refactored GodClass")
  end
  
  def self.retrieve_saved_data(attribute, for_example)
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
  
  def to_s
    "#{who} - #{id} - #{what}"
  end
end
