require 'json'

class SpaceReader
  attr_reader :jail, :go_to_jail
  def initialize(file)
    @file = file
    json = File.read(@file)
    @obj = JSON.parse(json)
    @spaces = []
  end

  # Convert the json objects into Space classes and subclasses
  # Returns the array of read-in spaces
  def get_spaces
    if not @spaces.empty?
      return @spaces
    end

    @obj["spaces"].each do |space|
      name = space["name"]
      space_num = space["space"]
      if not space.has_key?("type") # No "type" defaults to base class, Space
        @spaces.push(Space.new(name, space_num))
        next
      end

      case space["type"]
      when "property"
        @spaces.push(Property.new(name, space_num, space["color"], space["price"], space["rent"], space["mortgage"], space["house"], space["hotel"]))
      when "railroad"
        @spaces.push(Railroad.new(name, space_num, space["price"], space["rent"], space["mortgage"]))
      when "utility"
        @spaces.push(Utility.new(name, space_num, space["price"], space["rent"], space["mortgage"]))
      when "incomeTax"
        @spaces.push(Tax.new(name, space_num, space["tax"]))
      when "luxuryTax"
        @spaces.push(Tax.new(name, space_num, space["tax"]))
      when "chance"
        @spaces.push(Chance.new(space_num))
      when "communityChest"
        @spaces.push(CommunityChest.new(space_num))
      when "goToJail"
        @go_to_jail = space_num
        @spaces.push(Space.new(name, space_num))
      when "jail"
        @jail = space_num # Actual Jail isn't added in as a space, only the "Just Visiting" type. But, still keep track of which space number it is
      else
        raise "Invalid type '#{space["type"]}' found in '#{@file}'"
      end
    end
    return @spaces
  end
end
