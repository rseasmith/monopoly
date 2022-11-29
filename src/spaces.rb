class Space
  attr_reader :name, :space

  def initialize(name, space)
    @name = name
    @space = space
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
    super(name, space)
    if @@colors.include?(color.upcase)
      @@properties[color.upcase] += 1
    else
      @@colors << color.upcase
      @@properties[color.upcase] = 1
    end
    @price = price
    @rent = rent
    @mortgage = mortgage
    @house = house
    @hotel = hotel
  end
end

class Railroad < Space
  def initialize(name, space, price, rent, mortgage)
    super(name, space)
    @price = price
    @rent = rent
    @mortgage = mortgage
  end
end

class Utility < Space
  def initialize(name, space, price, rent, mortgage)
    super(name, space)
    @price = price
    @rent = rent
    @mortgage = mortgage
  end
end

class Tax < Space
  def initialize(name, space, tax)
    super(name, space)
    @tax = tax
  end
end

class Chance < Space
  def initialize(space)
    super("Chance", space)
  end
end

class CommunityChest < Space
  def initialize(space)
    super("Community Chest", space)
  end
end
