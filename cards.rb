class Card
  attr_reader :text

  def initialize(text)
    @text = text
  end

  def handle_event(player)
    puts "Throw an error?"
  end
end

class Chance < Card
  def initialize(text, event)
    super(text)
  end
end

class CommunityChest < Card
  def initialize(text, event)
    super(text)
  end
end
