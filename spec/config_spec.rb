require 'config'

RSpec.describe Config, "test" do
  it 'merging' do
    expect(Config['barracs']['cost_levels'][1]['time']).to eq(YAML.load_file('app/config/test.yml')['barracs']['cost_levels'][1]['time'])
    expect(Config['barracs']['unit']).to eq(YAML.load_file('app/config/default.yml')['barracs']['unit'])
    expect(Config['barracs']['cost_levels'][1]['time']).to eq(YAML.load_file('app/config/test.yml')['barracs']['cost_levels'][1]['time'])
    expect(Config['BLOCKS_IN_MAP_DIM']).to eq(YAML.load_file('app/config/test.yml')['BLOCKS_IN_MAP_DIM'])
  end

  it 'enving' do
    expect(ENV['ORBS_ENV']).to eq('test')
  end
end
