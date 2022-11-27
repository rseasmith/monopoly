require 'json'

class SpaceReader
  def initialize(file)
    json = File.read(file)
    @obj = JSON.parse(json)
  end

  def get_spaces
    @obj["spaces"].each do |space|
      if space.has_key?("type")

      else

      end
      #puts space.to_s
    end
  end
end
