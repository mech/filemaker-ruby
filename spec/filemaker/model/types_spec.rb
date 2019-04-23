describe Filemaker::Model::Types do
  let(:model) { MyModel.new }

  context 'Types::Text' do
    it 'assign as a string' do
      model.name = 'hello'
      expect(model.name).to be_a String
      expect(model.name).to eq 'hello'
    end

    it 'query as a string' do
      c = MyModel.where(name: 'hello')
      expect(c.selector['name']).to be_a String
      expect(c.selector['name']).to eq 'hello'
    end
  end

  context 'Types::Date' do
    it 'assign as a date' do
      model.created_at = Date.new(2018, 1, 1)
      expect(model.created_at).to be_a Date
      expect(model.created_at).to eq Date.new(2018, 1, 1)
    end

    it 'can query as a string' do
      c = MyModel.where(created_at: '12/2018')
      expect(c.selector['created_at']).to be_a String
      expect(c.selector['created_at']).to eq '12/2018'
    end

    it 'can query as a date' do
      c = MyModel.where(created_at: Date.new(2018, 1, 1))
      expect(c.selector['created_at']).to be_a Date
      expect(c.selector['created_at']).to eq Date.new(2018, 1, 1)
    end
  end

  context 'Types::DateTime' do
    it 'assign as a time' do
      model.updated_at = Time.new(2018, 1, 1, 12, 12, 12)
      expect(model.updated_at).to be_a Time
      expect(model.updated_at).to eq Time.new(2018, 1, 1, 12, 12, 12)
    end

    it 'assign as a datetime but return as time' do
      model.updated_at = DateTime.new(2018, 1, 1, 12, 12, 12)
      expect(model.updated_at).to be_a Time
      expect(model.updated_at).to eq Time.parse(model.updated_at.to_s)
    end

    it 'can query as a string' do
      c = MyModel.where(updated_at: '2018')
      expect(c.selector['modifieddate']).to be_a String
      expect(c.selector['modifieddate']).to eq '2018'
    end

    it 'can query as a datetime' do
      c = MyModel.where(updated_at: Time.new(2018, 1, 1, 12, 12, 12))
      expect(c.selector['modifieddate']).to be_a Time
      expect(c.selector['modifieddate']).to eq Time.new(2018, 1, 1, 12, 12, 12)
    end
  end

  context 'Types::DateTime' do
    it 'assign as time' do
      model.time_in = DateTime.new(2019, 1, 1, 9, 0, 0)
      expect(model.time_in).to be_a String
      expect(model.time_in).to eq '09:00'
    end

    it 'query with HH:MM format' do
      c = MyModel.where(time_in: Time.new(2019, 1, 1, 15, 45, 0))
      expect(c.selector['time_in']).to eq '15:45'
    end
  end

  context 'Types::BigDecimal' do
    it 'assign as a big decimal' do
      model.salary = '25'
      expect(model.salary).to be_a BigDecimal
      expect(model.salary).to eq 25.0
    end

    it 'query as a big decimal' do
      c = MyModel.where(salary: 23.7)
      expect(c.selector['salary']).to be_a BigDecimal
      expect(c.selector['salary']).to eq 23.7
    end
  end

  context 'Types::Integer' do
    it 'assign as an integer' do
      model.age = '25'
      expect(model.age).to be_a Integer
      expect(model.age).to eq 25
    end

    it 'query as an integer' do
      c1 = MyModel.where(age: 40)
      expect(c1.selector['passage of time']).to be_a Integer
      expect(c1.selector['passage of time']).to eq 40

      c2 = MyModel.where(age: '31')
      expect(c2.selector['passage of time']).to be_a Integer
      expect(c2.selector['passage of time']).to eq 31
    end
  end

  context 'Types::Email' do
    it 'assign as an email' do
      model.backup_email = 'bob@example.com'
      expect(model.backup_email).to be_a String
      expect(model.backup_email).to eq 'bob@example.com'
    end

    it 'query by replacing @ with \@' do
      c = MyModel.where(backup_email: 'bob@example.com')
      expect(c.selector['backup_email']).to be_a String
      expect(c.selector['backup_email']).to eq 'bob\@example.com'
    end
  end
end
