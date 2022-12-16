class Event
end

class AdvanceToSpace < Event
  attr_reader :space
  def initialize(space)
    @space = space
  end
end

class AdvanceToType < Event
  attr_reader :type
  def initialize(type)
    @type = type
  end
end

class Collect < Event
  attr_reader :collect
  def initialize(collect)
    @collect = collect
  end
end

class CollectEachPlayer < Event
  attr_reader :collect
  def initialize(collect)
    @collect = collect
  end
end

class GetOutOfJailFree < Event
end

class GoBackThree < Event
end

class GoToJail < Event
end

class Pay < Event
  attr_reader :pay
  def initialize(pay)
    @pay = pay
  end
end

class PayEachPlayer < Event
  attr_reader :pay
  def initialize(pay)
    @pay = pay
  end
end

class MakeRepairs < Event
  attr_reader :cost
  def initialize(cost)
    @cost = cost
  end
end
