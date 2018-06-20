describe Filemaker::Model::Builder do
  let(:model) { Job }
  let(:server) { Object.new }
  let(:xml) { import_xml_as_string('jobs.xml') }
  let(:resultset) { Filemaker::Resultset.new(server, xml) }

  context '.build' do
    let(:subject) do
      Filemaker::Model::Builder.build(resultset.first, model.new)
    end

    it 'has portals' do
      expect(subject.portals.keys).to eq([])
    end

    it 'has a status' do
      expect(subject.status).to eq('open')
    end

    it 'has an jdid' do
      expect(subject.jdid).to eq('JID1122')
    end

    it 'has a modify_date' do
      expect(subject.modify_date).to eq(Date.parse('2014-08-12'))
    end

    it 'is not dirty' do
      expect(subject.changed?).to eq false
      expect(subject.changes).to be_empty
    end
  end

  context '.collection' do
    let(:subject) do
      Filemaker::Model::Builder.collection(resultset, model)
    end

    it 'is an array of Jobs' do
      subject.each do |job|
        expect(job.class).to be(model)
      end
    end
  end
end
