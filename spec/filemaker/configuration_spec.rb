describe 'Configuration' do

  context 'with yaml file' do
    it 'load settings based on environment' do
      path = File.expand_path('../../support/filemaker.yml', __FILE__)
      Filemaker.load!(path, 'development')
      expect(Filemaker.registry['default']).to be_a Filemaker::Server
      expect(Filemaker.registry['default'].host).to eq 'host.com'
      expect(Filemaker.registry['default'].account_name).to eq \
        'FILEMAKER_ACCOUNT_NAME'
      expect(Filemaker.registry['default'].ssl).to eq({ 'verify' => false })
      expect(Filemaker.registry['default'].log).to eq :curl
    end

    it 'raises ConfigurationError for wrong environment' do
      path = File.expand_path('../../support/filemaker.yml', __FILE__)
      expect do
        Filemaker.load!(path, 'unknown')
      end.to raise_error Filemaker::Errors::ConfigurationError
    end
  end

end
