class CommitMessage
  
  def prompt
    prompt_lines = [
      PromptLine.new("pair", "bg/pg"),
      PromptLine.new("feature", "story 83"),
      PromptLine.new("message", "Refactored GodClass")
    ]
    
    messages = prompt_lines.collect {|prompt_line| prompt_line.prompt }
    messages.join(" - ")
  end
end
