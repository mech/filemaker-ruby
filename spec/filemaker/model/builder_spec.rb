describe Filemaker::Model::Builder do

  let(:model) { Job }
  let(:server) { Object.new }
  let(:xml) { import_xml_as_string('jobs.xml') }
  let(:resultset) { Filemaker::Resultset.new(server, xml) }

  context '.' do

    let(:subject) {
      Filemaker::Model::Builder.build(resultset.first, model.new)
    }

    it 'has portals' do
      expect(subject.portals.keys).to eq([])
    end

    it 'has a status' do
      expect(subject.status).to eq("open")
    end
    
    it 'has an jdid' do
      expect(subject.jdid).to eq("JID1122")
    end
    
    it 'has a modify_date' do
      expect(subject.modify_date).to eq(Date.parse('2014-08-12'))
    end
  end

  context '.collection' do

    let(:subject) { 
      Filemaker::Model::Builder.collection(resultset, model)
    }

    it 'is an array of Jobs' do
      subject.each do |job|
        expect(job.class).to be(model)
      end
    end
  end
end
