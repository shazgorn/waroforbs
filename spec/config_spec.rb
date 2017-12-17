RSpec.describe Config, "test" do
  it 'merging' do
    expect(Config['buildings']['barracs']['cost']['formula'][1]['time']).to eq(YAML.load_file('app/config/test.yml')['buildings']['barracs']['cost']['formula'][1]['time'])
    expect(Config['buildings']['barracs']['unit']).to eq(YAML.load_file('app/config/default.yml')['buildings']['barracs']['unit'])
    expect(Config['BLOCKS_IN_MAP_DIM']).to eq(YAML.load_file('app/config/test.yml')['BLOCKS_IN_MAP_DIM'])
  end

  it 'enving' do
    expect(ENV['ORBS_ENV']).to eq('test')
  end
end
