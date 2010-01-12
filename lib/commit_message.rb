class CommitMessage

  attr_reader :pair, :feature, :message

  def initialize
    @pair = PromptLine.new("pair", "bg & pg").prompt
    @feature = PromptLine.new("feature", "story 83").prompt
    @message = PromptLine.new("message", "Refactored blah").prompt
  end

  def joined_message
    [@pair, @feature, @message].join(' - ')
  end
end
