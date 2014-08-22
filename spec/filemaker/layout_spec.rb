describe Filemaker::Layout do

  it 'presets -db and -lay' do
    database = Filemaker::Database.new('candidates', double)
    layout = Filemaker::Layout.new('profile', double, database)
    expected_params = { '-db' => 'candidates', '-lay' => 'profile' }
    expect(layout.default_params).to eq expected_params
  end

  context 'api' do

    describe 'findany' do
      it 'find any one record' do
        server = Filemaker::Server.new do |config|
          config.host         = 'host'
          config.account_name = 'account_name'
          config.password     = 'password'
        end

        fake_post_response(server, nil, 'dbnames.xml')

        resultset = server.db['candidates']['Profile'].findany
        expect(resultset.params).to have_key('-findany')
        expect(resultset.params['-db']).to eq 'candidates'
        expect(resultset.params['-lay']).to eq 'Profile'
        expect(resultset.params['-findany']).to eq ''
      end

      it 'ignores -skip, -max, -sortfield, -sortorder options' do
      end
    end
  end
end
