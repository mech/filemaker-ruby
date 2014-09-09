describe Filemaker::Model::Relations do

  it 'every model has a relations hash' do
    expect(MyModel.new.relations).to eq({})
  end

  describe 'belongs_to' do
    context 'when using default reference_key' do
      before do
        @model = MyModel.new(candidate_id: '123')
        allow(Candidate).to receive(:where).and_return([Candidate.new])
      end

      it 'appends _id to missing reference_key' do
        expect(@model.candidate.reference_key).to eq 'candidate_id'
      end

      it 'target class should be Candidate' do
        expect(@model.candidate.target_class).to eq Candidate
      end

      it 'owner belongs to MyModel' do
        expect(@model.candidate.owner).to eq @model
      end

      it 'relations hash will be populated' do
        @model.candidate
        expect(@model.relations.fetch('candidate')).to eq \
          @model.candidate.target
      end
    end

    context 'when using supplied reference_key' do
      before do
        @model = MyModel.new(name: 'ABC')
        allow(User).to receive(:where).and_return([User.new])
      end

      it 'will use the supplied class_name' do
        expect(@model.applicant.target_class).to eq User
      end

      it 'will use the supplied reference_key' do
        expect(@model.applicant.reference_key).to eq :name
      end
    end

  end
end
