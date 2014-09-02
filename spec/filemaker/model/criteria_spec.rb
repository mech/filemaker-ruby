describe Filemaker::Model::Criteria do

  let(:model) { MyModel.new }
  let(:criteria) { Filemaker::Model::Criteria.new(model) }

  context 'selectable' do
    describe 'where' do
      it '' do
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
