class Event
  def initialize
    @multiplier = 1
  end
end

class AdvanceToSpace < Event
  def initialize(space)
  end

  def handle_event(player)
  end
end

class AdvanceToType < Event
  def initialize(type, multiplier)
  end
  
  def handle_event(player)
  end
end

class Collect < Event
  def handle_event(player)
  end
end

class CollectEachPlayer < Event
  def handle_event(player)
  end
end

class GetOutOfJailFree < Event
  def handle_event(player)
  end
end

class GoBackThree < Event
  def handle_event(player)
  end
end

class GoToJail < Event
  def handle_event(player)
  end
end

class Pay < Event
  def handle_event(player)
  end
end

class PayEachPlayer < Event
  def handle_event(player)
  end
end

class MakeRepairs < Event
  def handle_event(player)
  end
end
