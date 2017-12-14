require 'game'

RSpec.describe TownWorker, "testing" do
  it 'is creating worker' do
    w = TownWorker.new(1)
    w.start_res_collection(:gold, 1)
    expect(w.to_hash['res_title']).to eq(I18n.t('gold'))
    w.check_res
    w2 = TownWorker.new(2)
    w2.start_res_collection(:gold, 1, 1)
    expect(w2.to_hash['res_title']).to eq(I18n.t('gold'))
    w2.check_res
  end
end
