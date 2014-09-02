describe Filemaker::Model do

  let(:model) { MyModel.new }

  it 'sets up -db and -lay' do
    expect(MyModel.db).to eq :candidates
    expect(MyModel.lay).to eq :profile
    expect(model.db).to eq :candidates
    expect(model.lay).to eq :profile
  end

  it 'is a new record' do
    expect(model.new_record).to be true
  end

  it 'name and email default to UNTITLED' do
    expect(model.name).to eq 'UNTITLED'
    expect(model.email).to eq 'UNTITLED'
  end

  it 'stores the real FileMaker name under fm_name' do
    expect(model.fm_names).to eq \
      ['name', 'email', 'CA ID', 'created_at', 'ModifiedDate', 'salary']
  end

  it 'salary is BigDecimal' do
    model.salary = 100
    expect(model.salary).to be_a BigDecimal
  end

  it 'created_at is Date' do
    model.created_at = '4/12/2014'
    expect(model.created_at).to be_a Date
  end

  it 'check for presence of name and salary' do
    expect(model.name?).to be true
    expect(model.salary?).to be false
    model.salary = 100
    expect(model.salary?).to be true
  end

  describe 'process_attributes' do
    it 'accepts a hash of attributes' do
      model = MyModel.new(name: 'Bob', email: 'bob@cern.org')
      expect(model.name).to eq 'Bob'
      expect(model.email).to eq 'bob@cern.org'
    end

    # it 'is fun', :focus do
    #   Filemaker.load!('hey')
    #   puts Filemaker.registry
    # end
  end

end
