require 'time_helper'

RSpec.configure do |c|
  c.include TimeHelper
end

RSpec.describe TimeHelper, "testing" do
  it 'is time' do
    expect(seconds_to_hm 6).to eq('0:06')
    expect(seconds_to_hm 20).to eq('0:20')
    expect(seconds_to_hm 60).to eq('1:00')
    expect(seconds_to_hm 61).to eq('1:01')
    # no hours
    expect(seconds_to_hm 3600).to eq('60:00')
  end
end
