describe Filemaker::Server do

  context 'initializing a server' do
    it 'provides a host, account_name, and password' do
      server = Filemaker::Server.new do |config|
        config.host         = 'localhost'
        config.account_name = 'account_name'
        config.password     = 'password'
      end

      expect(server.host).to eq 'localhost'
      expect(server.account_name).to eq 'account_name'
      expect(server.password).to eq 'password'
      expect(server.connection).to be_a Faraday::Connection
      expect(server.connection.headers[:user_agent]).to \
        eq "filemaker-ruby-#{Filemaker::VERSION}"
      expect(server.connection.headers[:authorization]).to \
        eq 'Basic YWNjb3VudF9uYW1lOnBhc3N3b3Jk'
    end

    it 'did not provide host, account_name, and password' do
      expect do
        Filemaker::Server.new
      end.to raise_error ArgumentError

      expect do
        Filemaker::Server.new { |config| config.host = 'localhost' }
      end.to raise_error ArgumentError
    end
  end

  context 'initializing a server with SSL' do
    it 'indicates secured connection' do
      server = Filemaker::Server.new do |config|
        config.host         = 'localhost'
        config.account_name = 'account_name'
        config.password     = 'password'
        config.ssl          = { verify: false }
      end

      expect(server.connection.ssl[:verify]).to be false
    end
  end

  describe 'databases is a store to track encountered -db' do
    it 'stores database object and can be accessed with db and database' do
      server = Filemaker::Server.new do |config|
        config.host         = 'localhost'
        config.account_name = 'account_name'
        config.password     = 'password'
      end

      expect(server.databases['candidate']).to be_a Filemaker::Database
      expect(server.database['candidate']).to eq server.databases['candidate']
      expect(server.db['candidate']).to eq server.databases['candidate']
    end
  end

end
