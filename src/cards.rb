class Card
  attr_reader :text

  def initialize(text)
    @text = text
  end
end

class Chance < Card
  def initialize(text, event)
    super(text)
    @event = event
  end

  def handle_event(player)
    @event.handle_event(player)
  end
end

class CommunityChest < Card
  def initialize(text, event)
    super(text)
    @event = event
  end

  def handle_event(player)
    @event.handle_event(player)
  end
end
