describe Filemaker::Model::Criteria do

  let(:model) { MyModel.new }
  let(:criteria) { Filemaker::Model::Criteria.new(model) }
  let(:cf) { Filemaker::Api::QueryCommands::CompoundFind }

  context 'selectable' do
    describe 'where' do
      it 'raises MixedClauseError if mixed with -findquery' do
        expect do
          criteria.in(status: %w(pending subscribed)).where(name: 'Bob')
        end.to raise_error Filemaker::Error::MixedClauseError
      end

      it 'single hash criterion are recorded as is' do
        criteria.where(name: 'Bob', email: 'bob@cern.org')
        expect(criteria.selector).to eq(
          { 'name' => 'Bob', 'email' => 'bob@cern.org' }
        )
      end

      it 'chains where' do
        criteria.where(name: 'Bob').where(email: 'bob@cern.org')
        expect(criteria.selector).to eq(
          { 'name' => 'Bob', 'email' => 'bob@cern.org' }
        )
      end

      it 'accepts a block to configure additional options' do
        criteria.where(name: 'Bob') do |options|
          options[:script] = 'Remove Duplicates'
        end

        expect(criteria.options[:script]).to eq 'Remove Duplicates'
      end

      it 'only accepts fields from model' do
        criteria.where(name: 'Bob', email: 'bob@cern.org', unit: '< 50')
        expect(criteria.selector).to eq(
          { 'name' => 'Bob', 'email' => 'bob@cern.org' }
        )
      end
    end

    describe 'or' do
      it 'chains `or` as logical OR option' do
        criteria.where(name: 'Bob').or(email: 'bob@cern.org')
        expect(criteria.selector).to eq(
          { 'name' => 'Bob', 'email' => 'bob@cern.org' }
        )
        expect(criteria.options[:lop]).to eq 'or'
      end

      it 'chains multiple `or`, adding more fields' do
        criteria.where(name: 'Bob').or(email: 'bob@cern.org').or(salary: 5000)
        expect(criteria.selector).to eq(
          { 'name' => 'Bob', 'email' => 'bob@cern.org', 'salary' => 5000 }
        )
        expect(criteria.options[:lop]).to eq 'or'
      end
    end

    context 'comparison operators' do
      it 'only works on `where` query' do
        expect do
          criteria.in(status: %w(pending subscribed)).eq(name: 'Bob')
        end.to raise_error Filemaker::Error::MixedClauseError
      end

      describe 'not' do
        it 'append neq operator on the field name' do
          criteria.not(salary: 50)
          expect(criteria.selector['salary']).to eq 50
          expect(criteria.selector['salary.op']).to eq 'neq'
        end
      end

      # TODO: Do more operator tests
    end

    describe 'in' do
      it 'raises MixedClauseError if mixed with -find' do
        expect do
          criteria.where(name: 'Bob').in(status: %w(pending subscribed))
        end.to raise_error Filemaker::Error::MixedClauseError
      end

      it '{a: [1, 2]} to (q0);(q1)' do
        criteria.in(name: %w(Bob Lee))
        compound_find = cf.new(criteria.selector)
        expect(compound_find.key_maps_string).to eq '(q0);(q1)'
        expect(criteria.selector).to eq [{ 'name' => %w(Bob Lee) }]
      end

      it '{a: [1, 2], b: [3, 4]} to (q0,q2);(q0,q3);(q1,q2);(q1,q3)' do
        criteria.in(name: %w(Bob Lee), age: ['20', 30])
        compound_find = cf.new(criteria.selector)
        expect(compound_find.key_maps_string).to eq \
          '(q0,q2);(q0,q3);(q1,q2);(q1,q3)'
        expect(criteria.selector).to eq \
          [{ 'name' => %w(Bob Lee), 'passage of time' =>  [20, 30] }]
      end

      it '{a: [1, 2], b: 3} to (q0,q2);(q1,q2)' do
        criteria.in(name: %w(Bob Lee), age: '30')
        compound_find = cf.new(criteria.selector)
        expect(compound_find.key_maps_string).to eq '(q0,q2);(q1,q2)'
        expect(criteria.selector).to eq \
          [{ 'name' => %w(Bob Lee), 'passage of time' => 30 }]
      end

      it '{a: 1, b: 2} to (q0,q1)' do
        criteria.in(name: 'Bob', age: 30)
        compound_find = cf.new(criteria.selector)
        expect(compound_find.key_maps_string).to eq '(q0,q1)'
        expect(criteria.selector).to eq \
          [{ 'name' => 'Bob', 'passage of time' => 30 }]
      end

      it '{a: 1, b: [2, 3]} to (q0,q1);(q0,q2)' do
        criteria.in(name: 'Bob', age: [20, 30])
        compound_find = cf.new(criteria.selector)
        expect(compound_find.key_maps_string).to eq '(q0,q1);(q0,q2)'
        expect(criteria.selector).to eq \
          [{ 'name' => 'Bob', 'passage of time' => [20, 30] }]
      end

      it '[{a: [1, 2]}, {b: [1, 2]}] to (q0);(q1);(q2);(q3)' do
        criteria.in([{ name: %w(Bob Lee) }, { age: [20, 30] }])
        compound_find = cf.new(criteria.selector)
        expect(compound_find.key_maps_string).to eq '(q0);(q1);(q2);(q3)'
        expect(criteria.selector).to eq \
          [{ 'name' => %w(Bob Lee) }, { 'passage of time' => [20, 30] }]
      end

      it '[{a: 1}, {b: 2}] to (q0);(q1)' do
        criteria.in([{ name: 'Bob' }, { age: 20 }])
        compound_find = cf.new(criteria.selector)
        expect(compound_find.key_maps_string).to eq '(q0);(q1)'
        expect(criteria.selector).to eq \
          [{ 'name' => 'Bob' }, { 'passage of time' => 20 }]
      end

      it '[{a: 1}, {b: [1, 2]}] to (q0);(q1);(q2)' do
        criteria.in([{ name: 'Bob' }, { age: [20, 30] }])
        compound_find = cf.new(criteria.selector)
        expect(compound_find.key_maps_string).to eq '(q0);(q1);(q2)'
        expect(criteria.selector).to eq \
          [{ 'name' => 'Bob' }, { 'passage of time' => [20, 30] }]
      end

      it '[{a: 1}, {b: 1, c: 2}] to (q0);(q1,q2)' do
        criteria.in([{ name: 'Bob' }, { age: 20, email: 'A' }])
        compound_find = cf.new(criteria.selector)
        expect(compound_find.key_maps_string).to eq '(q0);(q1,q2)'
        expect(criteria.selector).to eq \
          [{ 'name' => 'Bob' }, { 'passage of time' => 20, 'email' => 'A' }]
      end
    end
  end

  context 'optional' do
    it 'accepts skip option' do
      criteria.skip(10)
      expect(criteria.options[:skip]).to eq 10
    end

    it 'will override skip if chain repeatedly' do
      criteria.skip(10).skip(100).skip(1000)
      expect(criteria.options[:skip]).to eq 1000
    end

    it 'accepts limit option' do
      criteria.limit(10)
      expect(criteria.options[:max]).to eq 10
    end

    it 'will override limit if chain repeatedly' do
      criteria.limit(10).limit(100).limit(1000)
      expect(criteria.options[:max]).to eq 1000
    end

    it 'accepts order option' do
      criteria.order('name desc')
      expect(criteria.options[:sortfield]).to eq ['name']
      expect(criteria.options[:sortorder]).to eq ['descend']
    end

    it 'does not entertain invalid fieldname' do
      criteria.order('zzz desc')
      expect(criteria.options[:sortfield]).to be_nil
      expect(criteria.options[:sortorder]).to be_nil
    end

    it 'will default to asc for missing order' do
      criteria.order('name, email')
      expect(criteria.options[:sortorder]).to eq %w(ascend ascend)
    end

    it 'will use real FileMaker fieldname' do
      criteria.order('updated_at desc')
      expect(criteria.options[:sortfield]).to eq ['ModifiedDate']
    end
  end

end
