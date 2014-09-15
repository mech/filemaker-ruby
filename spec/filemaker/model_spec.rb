describe Filemaker::Model do

  let(:model) { MyModel.new }

  it 'sets up -db and -lay' do
    expect(MyModel.db).to eq :candidates
    expect(MyModel.lay).to eq :profile
    expect(model.db).to eq :candidates
    expect(model.lay).to eq :profile
  end

  it 'sets up server and api' do
    expect(MyModel.api.default_params).to eq \
      ({ '-db' => :candidates, '-lay' => :profile })
    expect(MyModel.server.host).to eq 'host'
    expect(model.api.default_params).to eq \
      ({ '-db' => :candidates, '-lay' => :profile })
    expect(model.server.host).to eq 'host'
  end

  it 'is a new record' do
    expect(model.new_record).to be true
  end

  it 'has identity' do
    model.candidate_id = 'CA123'
    expect(model.id).to eq 'CA123'
  end

  it 'name and email default to UNTITLED' do
    expect(model.name).to eq 'UNTITLED'
    expect(model.email).to eq 'UNTITLED'
  end

  it 'stores the real FileMaker name under fm_name' do
    expect(model.fm_names).to eq \
      [
        'name',
        'email',
        'ca id',
        'created_at',
        'modifieddate',
        'salary',
        'passage of time'
      ]
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

    it 'will ignore nil values for fm_attributes' do
      model = MyModel.new(name: 'Bob', email: nil, candidate_id: '')
      expect(model.fm_attributes['name']).to eq 'Bob'
      expect(model.fm_attributes['ca id']).to eq ''
      expect(model.fm_attributes['email']).to be_nil
      expect(model.fm_attributes.size).to eq 2
    end
  end

end
