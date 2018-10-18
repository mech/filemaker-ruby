describe Filemaker::Model::Relations do
  it 'every model has a relations hash to store associations' do
    expect(MyModel.new.relations).to eq({})
  end

  describe 'belongs_to' do
    context 'when using default reference_key' do
      before do
        @model = MyModel.new(candidate_id: '123')
        allow(Candidate).to receive(:where).and_return([Candidate.new])
        allow(Member).to receive(:where).and_return([Member.new])
      end

      it 'appends _id to missing reference_key' do
        expect(@model.candidate.reference_key).to eq 'candidate_id'
        expect(@model.candidate.final_reference_key).to eq 'candidate_id'
      end

      it 'target class should be Candidate' do
        expect(@model.candidate.target_class).to eq Candidate
      end

      it 'reference_value is 123' do
        expect(@model.candidate.reference_value).to eq '123'
      end

      it 'owner belongs to MyModel' do
        expect(@model.candidate.owner).to eq @model
      end

      it 'relations hash will be populated' do
        @model.candidate
        expect(@model.relations.fetch('candidate')).to eq \
          @model.candidate.target
      end

      # Comment this test - because we return nil instead of Proxy object
      # it 'uses identity for missing reference_key' do
      #   expect(@model.member.reference_key).to eq 'member_id'
      #   expect(@model.member.final_reference_key).to eq 'id'
      # end

      it 'proxy blank?' do
        expect(@model.candidate.blank?).to eq false
        expect(@model.candidate.nil?).to eq false
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
        expect(@model.applicant.final_reference_key).to eq 'name'
      end

      it 'reference_value is ABC' do
        expect(@model.applicant.reference_value).to eq 'ABC'
      end
    end

    context 'when using source key' do
      before do
        @model = MyModel.new(manager_id: 'MG1')
        allow(Manager).to receive(:where).and_return([Manager.new])
      end

      it 'will use manager_id as final_reference_key' do
        expect(@model.manager.final_reference_key).to eq 'mg_id'
      end

      it 'reference_key is still manager_id' do
        expect(@model.manager.reference_key).to eq 'manager_id'
      end

      # Comment this test - because we return nil instead of Proxy object
      # it 'another_manager has different reference_key' do
      #   expect(@model.another_manager.reference_key).to eq :candidate_id
      # end
    end
  end

  describe 'has_many' do
    before do
      @model = MyModel.new(candidate_id: '123')
    end

    context 'when using default reference_key' do
      it 'will use owner identity name' do
        expect(@model.posts.reference_key).to eq 'candidate_id'
        expect(@model.posts.final_reference_key).to eq 'candidate_id'
      end

      it 'target class should be Post' do
        expect(@model.posts.target_class).to eq Post
      end

      it 'owner belongs to MyModel' do
        expect(@model.posts.owner).to eq @model
      end

      it 'returns criteria instead of an array of model objects' do
        expect(@model.posts).to be_a Filemaker::Model::Criteria
      end
    end

    context 'when using supplied reference_key' do
      it 'will use supplied class_name' do
        expect(@model.posters.target_class).to eq User
      end

      it 'will use the supplied reference_key' do
        expect(@model.posters.reference_key).to eq :email
        expect(@model.posters.final_reference_key).to eq 'email'
      end
    end

    context 'when using source key' do
      before do
        @model = Project.new
      end

      it 'will use id as reference_key' do
        expect(@model.project_members.reference_key).to eq :id
      end

      it 'will use project_id as source_key' do
        expect(@model.project_members.source_key).to eq :project_id
        expect(@model.project_members.final_reference_key).to eq 'project_id'
      end
    end
  end

  describe 'has_portal' do
  end
end
