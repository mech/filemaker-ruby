describe Filemaker::Store::DatabaseStore do

  it 'is a Hash' do
    store = Filemaker::Store::DatabaseStore.new(double(:server))
    expect(store).to be_a Hash
  end

  context 'storing a Database' do
    it 'keeps track of the database' do
      store = Filemaker::Store::DatabaseStore.new(double(:server))
      expect(store['candidate']).to be_a Filemaker::Database
      expect(store['candidate']).to eq store['candidate']
    end
  end

end
