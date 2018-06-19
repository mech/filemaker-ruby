describe Filemaker::Server do
  context 'initializing a server' do
    it 'provides a host, account_name, and password' do
      server = Filemaker::Server.new do |config|
        config.host         = 'example.com'
        config.account_name = 'account_name'
        config.password     = 'password'
      end

      expect(server.host).to eq 'example.com'
      expect(server.url).to eq 'http://example.com'
      expect(server.account_name).to eq 'account_name'
      expect(server.password).to eq 'password'
      expect(server.connection).to be_a Faraday::Connection
      expect(server.connection.headers[:user_agent]).to \
        eq "filemaker-ruby-#{Filemaker::VERSION}"
      expect(server.connection.headers[:authorization]).to \
        eq 'Basic YWNjb3VudF9uYW1lOnBhc3N3b3Jk'
    end

    it 'specifically ask for no SSL' do
      server = Filemaker::Server.new do |config|
        config.host         = 'example.com'
        config.account_name = 'account_name'
        config.password     = 'password'
        config.ssl          = false
      end

      expect(server.url).to eq 'http://example.com'
    end

    it 'did not provide host, account_name, and password' do
      expect do
        Filemaker::Server.new
      end.to raise_error ArgumentError

      expect do
        Filemaker::Server.new { |config| config.host = 'example.com' }
      end.to raise_error ArgumentError
    end
  end

  context 'initializing a server with SSL' do
    it 'indicates secured connection' do
      server = Filemaker::Server.new do |config|
        config.host         = 'example.com'
        config.account_name = 'account_name'
        config.password     = 'password'
        config.ssl          = { verify: false }
      end

      expect(server.url).to eq 'https://example.com'
      expect(server.connection.ssl[:verify]).to be false
    end
  end

  describe 'databases is a store to track encountered -db' do
    it 'stores database object and can be accessed with db and database' do
      server = Filemaker::Server.new do |config|
        config.host         = 'example.com'
        config.account_name = 'account_name'
        config.password     = 'password'
      end

      expect(server.databases['candidate']).to be_a Filemaker::Database
      expect(server.database['candidate']).to eq server.databases['candidate']
      expect(server.db['candidate']).to eq server.databases['candidate']
    end
  end

  context 'HTTP errors' do
    before do
      @server = Filemaker::Server.new do |config|
        config.host         = 'example.com'
        config.account_name = 'account_name'
        config.password     = 'password'
      end
    end

    it 'raises Filemaker::Errors::CommunicationError if status = 0' do
      # fake_error(@server, nil, 0)
      fake_typhoeus_error(0)

      expect do
        @server.databases.all
      end.to raise_error Filemaker::Errors::CommunicationError
    end

    it 'raises Filemaker::Errors::CommunicationError if status = 404' do
      # fake_error(@server, nil, 404)
      fake_typhoeus_error(404)

      expect do
        @server.databases.all
      end.to raise_error Filemaker::Errors::CommunicationError
    end

    it 'raises Filemaker::Errors::AuthenticationError if status = 401' do
      # fake_error(@server, nil, 401)
      fake_typhoeus_error(401)

      expect do
        @server.databases.all
      end.to raise_error Filemaker::Errors::AuthenticationError
    end
  end
end
