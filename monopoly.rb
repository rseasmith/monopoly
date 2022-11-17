require 'json'
require './player'

BOARD_JSON = './tiles.json'
CARDS_JSON = './cards.json'

DEBUG = false

class Monopoly
  attr_reader :board, :board_count

  def initialize
    @players = []
    @test = []
    @doubles = 0
    @rolls = 0
    load_board
  end

  def add_player(player)
    @players.push(player)
  end

  def get_space(num)
    return @board[num % @board.size]
  end

  def play_game
    @players.each do |player|
      take_turn(player)
    end
  end

  def debug_rolls(player)
    for i in 1..10000 do
      take_turn(player)
    end
    summarize
  end

  private

  def load_board
    load_tiles
    load_cards
  end

  def load_tiles
    #TODO: Make this read/load the json file with all the board info
    @board = []
    @board.push("Go")
    @board.push("Mediterranean Avenue")
    @board.push("Community Chest")
    @board.push("Baltic Avenue")
    @board.push("Income Tax")
    @board.push("Reading Railroad")
    @board.push("Oriental Avenue")
    @board.push("Chance")
    @board.push("Vermont Avenue")
    @board.push("Connecticut Avenue")
    @board.push("Jail")
    @board.push("St. Charles Place")
    @board.push("Electric Company")
    @board.push("States Avenue")
    @board.push("Virginia Avenue")
    @board.push("Pennsylvania Railroad")
    @board.push("St. James Place")
    @board.push("Community Chest")
    @board.push("Tennessee Avenue")
    @board.push("New York Place")
    @board.push("Free Parking")
    @board.push("Kentucky Avenue")
    @board.push("Chance")
    @board.push("Indiana Avenue")
    @board.push("Illinois Avenue")
    @board.push("B. & O. Railroad")
    @board.push("Atlantic Avenue")
    @board.push("Ventnor Avenue")
    @board.push("Water Works")
    @board.push("Marvin Gardens")
    @board.push("Go To Jail")
    @board.push("Pacific Avenue")
    @board.push("North Carolina Avenue")
    @board.push("Community Chest")
    @board.push("Pennsylvania Avenue")
    @board.push("Short Line")
    @board.push("Chance")
    @board.push("Park Place")
    @board.push("Luxury Tax")
    @board.push("Boardwalk")
    #puts "board.size = " + @board.size.to_s

    # Initialize board_count for keeping track of where players land
    @board_count = Array.new(@board.size, 0)

    #@test[4] = "Four"
    #@test[10] = "Ten"
    #puts @test.to_s
  end

  def load_cards
    # Read cards.json, intializing two arrays (chance & community_chest)
    # Randomize the order of them
  end

  def get_jail
    return 10
  end

  def get_go_to_jail
    return 30
  end
  # Roll dice
  # If in jai, check if player rolled doubles to get out or it's the 3rd turn in jail
  # Check if three doubles -> go to jail, end turn
  # Move player to correct tile (collect $200 if pass Go)
  # Handle event (buy property/pay rent/read card)
  # Check if doubles (if so, go again unless you were in jail)
  def take_turn(player)
    roll = player.roll
    @rolls += 1
    if DEBUG
      puts "Player rolled: " + roll.to_s
    end

    was_in_jail = player.in_jail?
    if player.in_jail?
      #puts "In jail. Turn " + player.turns_in_jail.to_s + ". Roll: " + player.rolls.to_s
      if player.turns_in_jail == 3 || player.doubles?
        #puts "Got out of jail!"
        player.turns_in_jail = 0
      else
        return
      end
    end

    if player.three_doubles?
      #puts "Three doubles! Go to jail."
      go_to_jail(player)
      @board_count[player.space] += 1
      return
    end

    move_player(player, roll)
    if DEBUG
      old = player.space
      puts "Moving from " + get_space(old) + " to space " + get_space(player.space).to_s
    end

    @board_count[player.space] += 1 # Increment count wherever the player ends their turn

    if player.doubles? && !player.in_jail? && !was_in_jail
      @doubles += 1
      #puts "Doubles! " + player.rolls.to_s + ". Go again!"
      take_turn(player)
    end
  end

  def move_player(player, roll)
    new_space = player.space + roll
    if new_space >= @board.size
      #puts "Pass Go! Collect $200"
    end

    if new_space == get_go_to_jail()
      go_to_jail(player)
      return
    end

    player.space = new_space % @board.size
  end

  def go_to_jail(player)
    #puts "clearing rolls: " + player.rolls.to_s
    player.rolls.clear()
    player.space = get_jail
    player.turns_in_jail += 1
    #puts "Player is in " + get_space(player.space)
  end

  def summarize
    puts "Final game summary:"
    puts "\tRolls: " + @rolls.to_s
    puts "\tDoubles: " + @doubles.to_s
    for i in 0..(@board_count.size-1)
      puts "\t" + get_space(i) + ": " + @board_count[i].to_s
    end
  end
end


player = Player.new("Player 1", "yo")
game = Monopoly.new
game.add_player(player)
game.debug_rolls(player)
