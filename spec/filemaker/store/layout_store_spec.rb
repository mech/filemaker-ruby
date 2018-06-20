describe Filemaker::Store::LayoutStore do
  it 'is a Hash' do
    store = Filemaker::Store::LayoutStore.new(double, double)
    expect(store).to be_a Hash
  end

  context 'storing a layout' do
    it 'keeps track of a layout' do
      store = Filemaker::Store::LayoutStore.new(double, double)
      expect(store['profile']).to be_a Filemaker::Layout
      expect(store['profile']).to equal store['profile']
    end
  end

  describe 'all' do
    it 'returns all layouts for a database' do
      server = Filemaker::Server.new do |config|
        config.host         = 'example.com'
        config.account_name = 'account_name'
        config.password     = 'password'
      end

      fake_typhoeus_post('layoutnames.xml')

      expect(server.db['candidates'].layouts.all).to eq \
        ['Dashboard', 'Calender', 'Profile', 'Resume', 'Job Application']
    end
  end
end
