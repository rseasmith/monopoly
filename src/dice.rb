# This represents the roll of two dice
class Dice
  attr_reader :first, :second
  def roll
    @first = rand(6) + 1
    @second = rand(6) + 1
    @first + @second
  end
end
