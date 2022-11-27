require 'logger'

require_relative 'src/player'
require_relative 'src/space_reader'
require_relative 'src/spaces'

SPACES_JSON = 'data/spaces.json'
CARDS_JSON = 'data/cards.json'

LOGGER_LEVEL = Logger::DEBUG # UNKNOWN/FATAL/ERROR/WARN/INFO/DEBUG
LOG_FILE = "log.out"
NUM_TURNS = 1000

class Monopoly
  def initialize
    @players = []
    @test = []
    @total_doubles = 0
    @total_rolls = 0
    if File.file?(LOG_FILE)
      File.delete(LOG_FILE)
    end
    @logger = Logger.new('log.out', File::WRONLY)
    @log = ""
    load_board
  end

  def add_player(player)
    @players.push(player)
  end

  def get_space(num)
    return @board[num % @board.size]
  end

  def play_game
    for i in 1..NUM_TURNS do
      @players.each do |player|
        take_turn(player)
      end
    end
  end

  def summarize
    puts "Final game summary:"
    puts "\tTotal Rolls: " + @total_rolls.to_s
    puts "\tDoubles: " + @total_doubles.to_s
    for i in 0..(@board_count.size-1)
      puts "\t" + get_space(i) + ": " + @board_count[i].to_s
    end
  end

  private

  def load_board
    load_spaces
    load_cards
  end

  def load_spaces
    @logger.debug("Loading board...")
    reader = SpaceReader.new(SPACES_JSON)
    spaces = reader.get_spaces()
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
  # If in jail, check if player rolled doubles to get out or it's the 3rd turn in jail
  # Check if three doubles -> go to jail, end turn
  # Move player to correct tile (collect $200 if pass Go)
  # Handle event (buy property/pay rent/read card)
  # Check if doubles (if so, go again unless you were in jail)
  def take_turn(player)
    @log.clear
    roll = player.roll
    @total_rolls += 1
    @log = player.name + ": Rolled " + player.last_roll.to_s + ". "

    was_in_jail = player.in_jail?
    if player.in_jail?
      @log = player.name + ": In jail. Turn " + player.turns_in_jail.to_s + ". Roll: " + player.last_roll.to_s + "."
      if player.doubles?
        @log = @log + " Doubles! Got out of jail."
        player.turns_in_jail = 0
      elsif player.turns_in_jail == 3
        @log = @log + ". Released after paying $50."
        player.turns_in_jail = 0
      else
        player.turns_in_jail += 1
        end_turn(player)
        return
      end
    end

    if player.three_doubles?
      @log = @log + " Three doubles!"
      go_to_jail(player)
      end_turn(player)
      return
    end

    move_player(player, roll)

    if player.doubles? && !player.in_jail? && !was_in_jail
      @total_doubles += 1
      @log = @log + " Doubles! Go again."
      end_turn(player)
      take_turn(player)
    else
      end_turn(player)
    end
  end

  def end_turn(player)
    @logger.debug(@log)
    @board_count[player.space] += 1 # Increment count wherever the player ends their turn
  end

  def move_player(player, roll)
    new_space = player.space + roll
    @log = @log + " Moving from " + get_space(player.space) + " to " + get_space(new_space % @board.size).to_s + "."
    if new_space >= @board.size
      @log = @log + " Pass Go! Collect $200."
    end

    if new_space == get_go_to_jail()
      go_to_jail(player)
      return
    end

    player.space = new_space % @board.size
  end

  def go_to_jail(player)
    @log = @log + " Sent to Jail."
    player.rolls.clear()
    player.space = get_jail
    player.turns_in_jail += 1
    @board_count[player.space] += 1 # Increment count wherever the player ends their turn
  end
end

player1 = Player.new("Player 1")
player2 = Player.new("Player 2")
player3 = Player.new("Player 3")
game = Monopoly.new
game.add_player(player1)
game.add_player(player2)
game.add_player(player3)
game.play_game()
game.summarize()
