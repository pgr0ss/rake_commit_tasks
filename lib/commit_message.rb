class CommitMessage

  attr_reader :pair, :feature, :message

  def initialize
    @pair = PromptLine.new("pair").prompt
    @feature = PromptLine.new("feature").prompt
    @message = PromptLine.new("message").prompt
  end

  def joined_message
    [@pair, @feature, @message].join(' - ')
  end
end
