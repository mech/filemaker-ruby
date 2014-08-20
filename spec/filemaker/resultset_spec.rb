describe Filemaker::Resultset do
  let(:server) do
    Filemaker::Server.new do |config|
      config.host         = 'http://host'
      config.account_name = 'account_name'
      config.password     = 'password'
    end
  end
  let(:xml) { import_xml_as_string('portal.xml') }
  let(:resultset) { Filemaker::Resultset.new(server, xml) }

  it 'has an internal array to hold on to records' do
    expect(resultset.list).to be_an Array
  end

  context 'parse XML record' do
    it 'assigns count' do
      expect(resultset.count).to eq 2
    end

    it 'assigns total_count' do
      expect(resultset.total_count).to eq 5000
    end

    it 'date-format is %m/%d/%Y for MM/dd/yyyy' do
      expect(resultset.date_format).to eq '%m/%d/%Y'
    end

    it 'time-format is %H:%M:%S for HH:mm::ss' do
      expect(resultset.time_format).to eq '%H:%M:%S'
    end

    it 'timestamp-format is %m/%d/%Y %H:%M:%S for MM/dd/yyyy HH:mm::ss' do
      expect(resultset.timestamp_format).to eq '%m/%d/%Y %H:%M:%S'
    end
  end

  describe 'build metadata' do
    it 'has 5 fields' do
      expect(resultset.fields.size).to eq 5
      expect(resultset.fields.keys).to eq ['PortalID', 'Year', 'Salary', 'Insurance Amount', 'Document']
    end

    it 'PortalID represented as Field object' do
      expect(resultset.fields['PortalID'].name).to eq 'PortalID'
      expect(resultset.fields['PortalID'].data_type).to eq 'text'
      expect(resultset.fields['PortalID'].field_type).to eq 'normal'
      expect(resultset.fields['PortalID'].global).to eq false
      expect(resultset.fields['PortalID'].repeats).to eq 1
      expect(resultset.fields['PortalID'].required).to eq true
    end

    it 'has 2 portals' do
      expect(resultset.portal_fields.size).to eq 2
    end
  end

  describe 'build records' do
    it 'has 2 records' do
      expect(resultset.list.size).to eq 2
    end
  end

end
