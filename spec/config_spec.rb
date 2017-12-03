require 'config'

RSpec.describe Config, "test" do
  it 'merging' do
    expect(YAML.load_file('config/app.yml')['barracs']['cost_time']).to eq(Config['barracs']['cost_time'])
    expect(YAML.load_file('config/app.default.yml')['barracs']['unit']).to eq(Config['barracs']['unit'])
  end
end
