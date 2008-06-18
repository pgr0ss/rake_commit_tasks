class CommitMessage < Struct.new(:who, :id, :what)
  def self.prompt
    new retrieve_saved_data("pair", "bg/pg"),
        retrieve_saved_data("feature", "story 83"),
        retrieve_saved_data("message", "Refactored GodClass")
  end
  
  def to_s
    "#{who} - #{id} - #{what}"
  end
end
