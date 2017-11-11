require "celluloid/current"

require 'game'
require 'facade'

module AttackHelpers
  def facade_attack(token, id)
    facade.parse_data({
                        'writer_name' => 'attacker',
                        'token' => token,
                        'op' => 'attack',
                        'params' => {
                          'id' => id
                        }
                      })
  end
end

RSpec.configure do |c|
  c.include AttackHelpers
end

RSpec.describe Facade, "#parse_data" do
  around do |ex|
    Celluloid.boot
    Celluloid::Actor[:game] = Game.new(true)
    ex.run
    Celluloid.shutdown
  end

  let(:facade) { Facade.new }
  let(:writer_name) { 'test' }

  it "sends message without writer name" do
    user_data = facade.parse_data 'test'
    expect(user_data).to be_nil
  end

  it "sends message without token" do
    user_data = facade.parse_data({'writer_name' => writer_name})
    expect(user_data[writer_name][:error]).to eq('No token')
  end

  it "gets no op" do
    user_data = facade.parse_data({'writer_name' => writer_name, 'token' => 'test_token'})
    expect(user_data[writer_name][:error]).to eq('No op')
  end

  it "tests init routine" do
    user_data = facade.parse_data({
                                    'writer_name' => writer_name,
                                    'token' => 'test_token',
                                    'op' => 'init_map'
                                  })
    expect(user_data[writer_name][:error]).to be_nil
    expect(user_data[writer_name][:data_type]).to eq(:init_map)
  end

  it 'user attack' do
    att_token = 'attacker_token'
    def_token = 'defender_token'
    facade.parse_data({
                        'writer_name' => 'attacker',
                        'token' => att_token,
                        'op' => 'init_map'
                      })
    facade.parse_data({
                        'writer_name' => 'defender',
                        'token' => def_token,
                        'op' => 'init_map'
                      })
    a_user = Celluloid::Actor[:game].get_user_by_token(att_token)
    d_user = Celluloid::Actor[:game].get_user_by_token(def_token)
    a = Unit.get_by_id(a_user.active_unit_id)
    a.move_to(1, 1, 0)
    d = Unit.get_by_id(d_user.active_unit_id)
    d.move_to(2, 2, 0)
    10.times do
      facade_attack(att_token, d.id)
    end
  end

  fit 'restart' do
    token = 'restarter'
    facade.parse_data({
                        'writer_name' => token,
                        'token' => token,
                        'op' => 'init_map'
                      })
    user_data = facade.parse_data({
                                    'writer_name' => token,
                                    'token' => token,
                                    'op' => 'restart'
                                  })
    user = Celluloid::Actor[:game].get_user_by_token(token)
    expect(Unit.get_by_user(user).first.id).to eq(user_data[token][:active_unit_id])
  end
end
