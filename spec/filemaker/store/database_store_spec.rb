describe Filemaker::Store::DatabaseStore do

  it 'is a Hash' do
    store = Filemaker::Store::DatabaseStore.new(double(:server))
    expect(store).to be_a Hash
  end

  context 'storing a Database' do
    it 'keeps track of a database' do
      store = Filemaker::Store::DatabaseStore.new(double(:server))
      expect(store['candidate']).to be_a Filemaker::Database
      expect(store['candidate']).to equal store['candidate']
    end
  end

  describe 'all' do
    it 'returns all databases' do
      server = Filemaker::Server.new do |config|
        config.host         = 'https://host'
        config.account_name = 'account_name'
        config.password     = 'password'
        config.ssl          = { verify: false }
      end

      server.connection.builder.use Faraday::Adapter::Test do |stub|
        stub.get '/fmi/xml/fmresultset.xml?-dbnames=' do
          [200, {}, import_xml_as_string('dbnames.xml')]
        end
      end

      expected_result = %w(Billing Candidates Employee Jobs)

      expect(server.databases.all).to eq expected_result
      expect(server.database.all).to eq expected_result
      expect(server.db.all).to eq expected_result
    end
  end

end
