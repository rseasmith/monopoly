require 'json'

require_relative 'events'
require_relative 'spaces'

class CardReader
  attr_reader :chance, :community_chest
  def initialize(file)
    @file = file
    json = File.read(@file)
    @obj = JSON.parse(json)
    @chance = []
    @community_chest = []
    @cards = get_cards
  end

private

  def get_cards()
    @obj["cards"].each do |card|
      text = card["text"]

      case card["event"]
      when "advanceToType"
        if (card["type"] == "railroad")
          event = AdvanceToType.new(Railroad, card["multiplier"])
        elsif (card["type"] == "utility")
          event = AdvanceToType.new(Utility, card["multiplier"])
        else
          raise "Invalid type '#{card["type"]}'."
        end
      when "advanceToSpace"
        event = AdvanceToSpace.new(card["space"])
      when "pay"
        event = Pay.new(card["pay"])
      when "getOutOfJailFree"
        event = GetOutOfJailFree.new
      when "goToJail"
        event = GoToJail.new
      when "goBackThree"
        event = GoBackThree.new
      when "collect"
        event = Collect.new(card["collect"])
      when "payEachPlayer"
        event = PayEachPlayer.new(card["pay"])
      when "makeRepairs"
        event = MakeRepairs.new(card["cost"])
      when "collectEachPlayer"
        event = CollectEachPlayer.new(card["collect"])
      else
        raise "Invalid type '#{card["event"]}' found in '#{@file}'."
      end

      if card["cardType"] == "chance"
        @chance.push(ChanceCard.new(text, event))
      elsif card["cardType"] == "communityChest"
        @community_chest.push(CommunityChestCard.new(text, event))
      end
    end
  end
end
