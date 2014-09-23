describe Filemaker::Store::ScriptStore do

  it 'is a Hash' do
    store = Filemaker::Store::ScriptStore.new(double, double)
    expect(store).to be_a Hash
  end

  context 'storing a script' do
    it 'keeps track of a script' do
      store = Filemaker::Store::ScriptStore.new(double, double)
      expect(store['print']).to be_a Filemaker::Script
      expect(store['print']).to equal store['print']
    end
  end

  describe 'all' do
    it 'returns all scripts for a database' do
      server = Filemaker::Server.new do |config|
        config.host         = 'example'
        config.account_name = 'account_name'
        config.password     = 'password'
      end

      fake_post_response(server, nil, 'scriptnames.xml')

      expect(server.db['candidates'].scripts.all).to eq \
        ['library', 'open job', 'copy resume']
    end
  end

end
