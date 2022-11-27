require_relative 'dice'

class Player
  attr_reader :name, :last_roll, :rolls
  attr_writer :in_jail
  attr_accessor :space, :turns_in_jail

  def initialize(name)
    @name = name
    @space = 0
    @dice = Dice.new
    @last_roll = []
    @rolls = []
    @turns_in_jail = 0
  end

  # :rolls is ordered from oldest->newest with newest at the end
  def roll
    roll = @dice.roll
    @last_roll = [@dice.first, @dice.second]
    @rolls.push(@last_roll)
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

  # @turns_in_jail is incremented at the end of each roll starting with the roll that sent you to jail
  # i.e., checking this value tells you if this is your first, second, or third turn in jail
  def in_jail?
    return @turns_in_jail > 0
  end
end
