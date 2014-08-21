describe Filemaker::Layout do

  it 'preset -db and -lay' do
    database = Filemaker::Database.new('candidates', double)
    layout = Filemaker::Layout.new('profile', double, database)
    expected_params = { '-db' => 'candidates', '-lay' => 'profile' }
    expect(layout.default_params).to eq expected_params
  end
end
