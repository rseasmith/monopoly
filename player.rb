require './dice'

class Player
  attr_reader :name, :rolls
  attr_writer :in_jail
  attr_accessor :space, :turns_in_jail

  def initialize(name, tile)
    @name = name
    @space = 0
    @dice = Dice.new
    @rolls = []
    @turns_in_jail = 0
  end

  # :rolls is ordered from oldest->newest with newest at the end
  def roll
    roll = @dice.roll
    @rolls.push([@dice.first, @dice.second])
    if @rolls.size > 3
      @rolls.shift
    end
    return roll
  end

  def doubles?
    if @rolls.last != nil
      return @rolls.last[0] == @rolls.last[1]
    end
    return false
  end

  # Check if the previous 3 rolls are doubles
  def three_doubles?
    if @rolls.size == 3
      result = true
      @rolls.each do |roll|
        if (roll[0] == roll[1])
          result &= true
        else
          result &= false
        end
      end
      return result
    else
      return false
    end
  end

  def in_jail?
    return @turns_in_jail > 0
  end
end
