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
    @spaces = []
    @space_count = {}
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
    return @spaces[num % @spaces.size].name
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
    @space_count.each do |k,v|
      puts "\t" + k + ": " + v.to_s
    end
  end

  private

  def load_board
    load_spaces
    load_cards
  end

  # Read in SPACES_JSON and populate @spaces.
  # Then initialize @space_count, appending "In Jail"
  def load_spaces
    @logger.debug("Loading board...")
    reader = SpaceReader.new(SPACES_JSON)
    @spaces = reader.get_spaces()
    @jail = reader.jail
    @go_to_jail = reader.go_to_jail

    # Initialize space_count for keeping track of where players land
    # Add an extra space at the end to keep track of number of turns ended fully in jail (not "Just Visiting")
    @spaces.each do |space|
      @space_count[space.name] = 0
    end
    @space_count["In Jail"] = 0
  end

  def load_cards
    # Read cards.json, intializing two arrays (chance & community_chest)
    # Randomize the order of them
  end

  def get_jail
    return @jail
  end

  def get_go_to_jail
    return @go_to_jail
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

    # You can only get out of jail by rolling doubles or paying $50. Assume player only pays $50 after expending all 3 attempts to escape
    was_in_jail = player.in_jail?
    if player.in_jail?
      @log = player.name + ": In jail. Turn " + player.turns_in_jail.to_s + ". Roll: " + player.last_roll.to_s + "."
      if player.doubles?
        @log = @log + " Doubles! Got out of jail."
        player.turns_in_jail = 0
      elsif player.turns_in_jail == 3
        @log = @log + " Released after paying $50."
        player.turns_in_jail = 0
      else
        player.turns_in_jail += 1
        end_turn(player)
        return
      end
    end

    if player.three_doubles? # 3 doubles immediately sends you to jail and ends your turn
      @log = @log + " Three doubles!"
      go_to_jail(player)
      end_turn(player)
      return
    end

    move_player(player, roll) # Barring jail or 3 doubles, move player normally

    handle_card(player) # If the new space is a Chance or Community Chest, grab the next card and handle the event

    if player.doubles? && !player.in_jail? && !was_in_jail # Doubles gets you another turn UNLESS you were just sent to jail or just escaped from jail
      @total_doubles += 1
      @log = @log + " Doubles! Go again."
      end_turn(player)
      take_turn(player)
    else
      end_turn(player)
    end
  end

  # Output to the logfile, and keep track of which space the player ended their turn on
  def end_turn(player)
    @logger.debug(@log)
    # Increment space_count wherever the player ends their turn
    if player.in_jail?
      @space_count["In Jail"] += 1
    else
      @space_count[@spaces[player.space].name] += 1
    end
  end

  def move_player(player, roll)
    new_space = player.space + roll
    @log = @log + " Moving from " + get_space(player.space) + " to " + get_space(new_space % @spaces.size).to_s + "."
    if new_space >= @spaces.size
      @log = @log + " Pass Go! Collect $200."
    end

    if new_space == get_go_to_jail()
      go_to_jail(player)
      return
    end

    player.space = new_space % @spaces.size
  end

  def handle_card(player)
    if (@spaces[player.space].is_a?(Chance))
      @log = @log + " Chance!"
    elsif (@spaces[player.space].is_a?(CommunityChest))
      @log = @log + " Community Chest!"
    end
  end

  def go_to_jail(player) # Sends player to jail and increments turns_in_jail by 1
    @log = @log + " Go to Jail."
    player.rolls.clear()
    player.space = get_jail
    player.turns_in_jail += 1
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
