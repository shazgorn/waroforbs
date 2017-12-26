require 'game'

RSpec.describe Town, "testing" do
  around do |ex|
    Celluloid.boot
    Celluloid::Actor[:game] = Game.new(true)
    ex.run
    Celluloid.shutdown
  end

  it 'aid town' do
    user = User.new('towner')
    town = Town.new(1, 1, user)
    aid = TownAid.new(town)
    aid.aid
  end
end
