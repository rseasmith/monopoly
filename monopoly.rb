require 'logger'

require_relative 'src/cards'
require_relative 'src/card_reader'
require_relative 'src/player'
require_relative 'src/space_reader'
require_relative 'src/spaces'

SPACES_JSON = 'data/spaces.json'
CARDS_JSON = 'data/cards.json'

LOGGER_LEVEL = Logger::DEBUG #UNKNOWN/FATAL/ERROR/WARN/INFO/DEBUG
LOG_FILE = "log.out"
NUM_TURNS = 1000

class Monopoly
  attr_reader :jail, :go_to_jail
  def initialize
    @players = []
    @spaces = []
    @chance = []
    @chance_discard = []
    @community_chest = []
    @community_chest_discard = []
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

  # Get the name of the space (e.g. Boardwalk) from a given space number (e.g. 39)
  def get_space_name(num)
    return @spaces[num % @spaces.size].name
  end

  # Get the number of the space (e.g. 39) from a given space name (e.g. Boardwalk)
  def get_space_num(name)
    @spaces.each_with_index do |space,i|
      if space.name == name
        return i
      end
    end
    # Log an error if there's an invalid name request
    @logger.error("Invalid space name '#{name}' requested in 'get_space_num' function.")
    return -1
  end

  def play_game
    for i in 1..NUM_TURNS do
      @players.each do |player|
        @log.clear
        @log = "\n" + player.name + ":"
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
  # Then initialize @space_count with "In Jail" and append @spaces names
  def load_spaces
    @logger.debug("Loading spaces from '" + SPACES_JSON + "'...")
    reader = SpaceReader.new(SPACES_JSON)
    @spaces = reader.get_spaces
    @jail = reader.jail
    @go_to_jail = reader.go_to_jail

    # Initialize space_count for keeping track of where players land
    # Since space_count is a hash, prepend the space number to differentiate spaces with the same name (e.g. "Chance")
    # Add an extra space at the beginning to keep track of number of turns ended fully in jail (not "Just Visiting")
    @space_count["(-) In Jail"] = 0
    @spaces.each do |space|
      @space_count["(" + space.space.to_s + ") " + space.name] = 0
    end
  end

  # Read in CARDS_JSON, initializing @chance and @community_chest
  def load_cards
    @logger.debug("Loading cards from '" + CARDS_JSON + "'...")
    reader = CardReader.new(CARDS_JSON)
    @chance = reader.chance.shuffle
    @community_chest = reader.community_chest.shuffle
    # puts "Chance: " + @chance.to_s
    # puts "Community Chest: " + @community_chest.to_s
  end

  # Roll dice
  # If in jail, check if player rolled doubles to get out or it's the 3rd turn in jail
  # Check if three doubles -> go to jail, end turn
  # Move player to correct tile (collect $200 if pass Go)
  # Handle event (buy property/pay rent/read card)
  # Check if doubles (if so, go again unless you were in jail)
  def take_turn(player)
    roll = player.roll
    @total_rolls += 1
    append("Rolled " + player.last_roll.to_s)

    was_in_jail = false

    # If player is in jail, try to get out
    if player.in_jail?
      was_in_jail = true
      if (!try_to_get_out_of_jail(player)) # Failing to get out of jail ends the player's turn
        return
      end
    end

    # 3 doubles immediately sends you to jail and ends your turn
    if player.three_doubles?
      append("Three doubles!")
      go_to_jail(player)
      end_turn(player)
      return
    end

    # Barring jail or 3 doubles, move player normally
    move_player(player, roll)

    # If the new space is a Chance or Community Chest, grab the next card and handle the event
    if @spaces[player.space].is_a?(ChanceSpace) or @spaces[player.space].is_a?(CommunityChestSpace)
      handle_card(player)
    end

    # Doubles gets you another turn UNLESS you were just sent to jail or just escaped from jail
    if player.doubles? && !player.in_jail? && !was_in_jail
      @total_doubles += 1
      append("Doubles! Go again.")
      end_turn(player)
      take_turn(player)
    else
      end_turn(player)
    end
  end

  # Logic for trying to get player out of jail. Return 'true' if player escapes. False, otherwise
  def try_to_get_out_of_jail(player)
    # You can only get out of jail by having a get out of jail free card, rolling doubles, or paying $50.
    # Assume player
    # 1) Uses get out of jail if they have it
    # 2) Tries to roll doubles
    # 3) Only pays $50 after expending all 3 attempts to escape
    append("In jail. Turn " + player.turns_in_jail.to_s)
    if player.get_out_of_jail_free?
      append("Using Get Out of Jail Free card!")
      card = player.get_out_of_jail.shift
      if (card.is_a?(ChanceCard))
        @chance_discard.unshift(card)
      else
        @community_chest_discard.unshift(card)
      end
      player.turns_in_jail = 0
      player.rolls.clear
      return true
    end

    append("Roll: " + player.last_roll.to_s)
    if player.doubles?
      append("Doubles! Got out of jail.")
      player.turns_in_jail = 0
      player.rolls.clear
      return true
    elsif player.turns_in_jail == 3
      append("Released after paying $50.")
      player.turns_in_jail = 0
      player.rolls.clear
      return true
    else
      append("Unsuccessful.")
      player.turns_in_jail += 1
      end_turn(player)
      return false
    end
  end

  # Output to the logfile, and keep track of which space the player ended their turn on
  def end_turn(player)
    @logger.debug(@log)
    # Increment space_count wherever the player ends their turn
    if player.in_jail?
      @space_count["(-) In Jail"] += 1
    else
      @space_count["(" + @spaces[player.space].space.to_s + ") " + @spaces[player.space].name] += 1
    end
  end

  # Advance player ahead by amount of roll.
  # If player passes Go they receive $200. If they land on "Go To Jail" they are sent to jail
  def move_player(player, roll)
    new_space = (player.space + roll) % @spaces.size
    append("Moving from '" + get_space_name(player.space) + " (#{player.space})' to '" + get_space_name(new_space).to_s + " (#{new_space})'.")

    if new_space == @go_to_jail
      go_to_jail(player)
      return
    end

    if (player.space + roll) >= @spaces.size
      append("Pass Go! Collect $200.")
    end

    player.space = new_space
  end

  # Handle the logic of the event from a given Chance/Community Chest card
  def handle_card(player)
    card = get_card(player)

    if card == nil
      @logger.error("Error! '#{player.name}' tried to call 'handle_card' while player was on '#{player.space}'.")
      return
    end

    append("Drew: " + card.text)

    case card.event
    when AdvanceToType
      space = get_nearest_type(card.event.type, player.space)
      move_player(player, space)
    when AdvanceToSpace
      space = get_space_num(card.event.space)
      move = space + (@spaces.size - player.space)
      move_player(player, move)
    when Pay
      append("Paying $#{card.event.pay}.")
    when GetOutOfJailFree
      player.get_out_of_jail.unshift(card)
      append("Get out of jail free card count: #{player.get_out_of_jail.size}.")
      return # Return before discarding as card is kept
    when GoToJail
      go_to_jail(player)
    when GoBackThree
      move_player(player, -3)
    when Collect
      append("Collecting $#{card.event.collect}.")
    when PayEachPlayer
      append("Paying each player $#{card.event.pay}.")
    when MakeRepairs
      append("Making repairs: $#{card.event.cost[0]} per house, $#{card.event.cost[0]} per hotel.")
    when CollectEachPlayer
      append("Collecting $#{card.event.collect} from each player.")
    else
      raise "Invalid type '#{card.event}': " + card.event.to_s
    end

    if (card.is_a?(ChanceCard))
      @chance_discard.unshift(card)
    else
      @community_chest_discard.unshift(card)
    end
  end

  def get_card(player)
    if (@spaces[player.space].is_a?(ChanceSpace))
      if @chance.empty?
        @logger.debug("Chance empty. Shuffling...")
        @chance = @chance_discard.shuffle
        @chance_discard.clear
      end
      return @chance.shift
    elsif (@spaces[player.space].is_a?(CommunityChestSpace))
      if @community_chest.empty?
        @logger.debug("Community Chest empty. Shuffling...")
        @community_chest = @community_chest_discard.shuffle
        @community_chest_discard.clear
      end
      return @community_chest.shift
    else
      return nil
    end
  end

  # Get the number of spaces for the nearest type (railroad or utility) from a given space
  def get_nearest_type(type, space)
    for i in 1..@spaces.size do
      new_space = (i + space) % @spaces.size
      if (@spaces[new_space].is_a?(type))
        return i
      end
    end
    raise "Unable to find nearest type: '#{type}'"
  end

  # Sends player to jail and increments turns_in_jail by 1
  def go_to_jail(player)
    append("Go to Jail.")
    player.rolls.clear
    player.space = @jail
    player.turns_in_jail += 1
  end
end

  # For appending to the log
  def append(text)
    @log = @log + "\n\t" + text
  end

player1 = Player.new("Player 1")
player2 = Player.new("Player 2")
player3 = Player.new("Player 3")
game = Monopoly.new
game.add_player(player1)
game.add_player(player2)
game.add_player(player3)
game.play_game
game.get_space_num("Boardwalk")
game.get_space_num("lol")
game.summarize
