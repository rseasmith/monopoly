class Space
  attr_reader :name, :type

  def initialize(name, space, jail, go_to_jail)
    @name = name
    @jail = jail
    @go_to_jail = jail
  end
end

class Property < Space
  @@colors = []
  @@properties = {}
  def self.colors
    @@colors
  end
  def self.properties
    @@properties
  end
  def initialize(name, space, color, price, rent, mortgage, house, hotel)
    super(name, space, false, false)
    if @@colors.include?(color.upcase)
      @@properties[color.upcase] += 1
    else
      @@colors << color.upcase
      @@properties[color.upcase] = 1
    end
  end
end

class Railroad < Space
  def initialize(name, space, price, rent, mortgage)
    super(name, space, false, false)
  end
end

class Utility < Space
  def initialize(name, space, price, rent, mortgage)
    super(name, space, false, false)
  end
end

class Chance < Space
  def initialize(space)
    super("Chance", space, false, false)
  end
end

class CommunityChest < Space
  def initialize(space)
    super("Community Chest", space, false, false)
  end
end

class Tax < Space
  def initialize(name, space, tax)
    super(name, space, false, false)
  end
end
