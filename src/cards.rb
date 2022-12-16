class Card
  attr_reader :text, :event

  def initialize(text)
    @text = text
    @event = nil
  end
end

class ChanceCard < Card
  def initialize(text, event)
    super(text)
    @event = event
  end
end

class CommunityChestCard < Card
  def initialize(text, event)
    super(text)
    @event = event
  end
end
