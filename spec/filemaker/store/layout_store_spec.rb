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
        config.host         = 'https://host'
        config.account_name = 'account_name'
        config.password     = 'password'
        config.ssl          = { verify: false }
      end

      server.connection.builder.use Faraday::Adapter::Test do |stub|
        stub.get '/fmi/xml/fmresultset.xml?-db=candidates&-layoutnames=' do
          [200, {}, import_xml_as_string('layoutnames.xml')]
        end
      end

      expect(server.db['candidates'].layouts.all).to eq \
        ['Dashboard', 'Calender', 'Profile', 'Resume', 'Job Application']
    end
  end

end
