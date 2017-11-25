require 'game'

RSpec.describe TownWorker, "testing" do
  fit 'is creating worker' do
    w = TownWorker.new(1)
    w.start_res_collection(:gold, 1)
    expect(w.to_hash['res_title']).to eq(I18n.t('gold'))
  end
end
