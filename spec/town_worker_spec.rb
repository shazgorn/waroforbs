require 'game'

RSpec.describe TownWorker, "testing" do
  it 'is creating worker' do
    bc = BuildingContainer.new({
                                 :factory => Factory.new,
                                 :roads => Roads.new
                               })
    w = TownWorker.new(1, bc)
    w.start_res_collection(:gold, 1)
    expect(w.to_hash['res_title']).to eq(I18n.t('gold'))
    w.collect_res
    w2 = TownWorker.new(2, bc)
    w2.start_res_collection(:gold, 1)
    expect(w2.to_hash['res_title']).to eq(I18n.t('gold'))
    w2.collect_res
  end
end
