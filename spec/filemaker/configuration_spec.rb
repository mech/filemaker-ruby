describe 'Configuration' do

  context 'with yaml file' do
    it 'load settings based on environment' do
      path = File.expand_path('../../support/filemaker.yml', __FILE__)
      Filemaker.load!(path, 'development')
      expect(Filemaker.registry["default"]).to be_a Filemaker::Server
      expect(Filemaker.registry["default"].host).to eq 'host.com'
      expect(Filemaker.registry["default"].account_name).to eq \
        'FILEMAKER_ACCOUNT_NAME'
    end
  end

end