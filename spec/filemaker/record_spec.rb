describe Filemaker::Record do
  before do
    server = Filemaker::Server.new do |config|
      config.host         = 'http://host'
      config.account_name = 'account_name'
      config.password     = 'password'
    end

    xml = import_xml_as_string('portal.xml')
    resultset = Filemaker::Resultset.new(server, xml)
    records = Nokogiri::XML(xml).remove_namespaces!.xpath('/fmresultset/resultset/record')
    @record = Filemaker::Record.new(records.first, resultset)
  end

  it 'acts as a Hash' do
    expect(@record).to be_a Hash
  end

  it 'records mod-id and record-id' do
    expect(@record.mod_id).to eq 'mod-id-1'
    expect(@record.record_id).to eq 'record-id-1'
  end

  it 'has 5 fields' do
    expect(@record.size).to eq 5
  end

  it 'empty <data/> should be nil' do
    expect(@record['Insurance Amount']).to be_nil
  end

  it 'text should be String' do
    expect(@record['PortalID']).to eq '1234'
  end

  it 'Salary should be an array of BigDecimal' do
    expect(@record['Salary']).to be_an Array
    expect(@record['SALARY']).to eq [BigDecimal.new(5000), BigDecimal.new(6000)]
  end

  it 'has 2 portals' do
    expect(@record.portals.size).to eq 2
    # Test for case insensitive hash!
    expect(@record.portals[:PORTAL_1]).to eq @record.portals['portal_1']
  end

  it 'has 4 records for PORTAL_2' do
    expect(@record.portals[:PORTAL_2].size).to eq 4
    expect(@record.portals[:PORTAL_2][1]['portal_2::expired']).to be_nil
  end

  it 'key access as plain method' do
    expect(@record.portalid).to eq '1234'
  end

  context 'dirty checking' do
    it 'tracks changes if you modify any value' do
      @record.year = 2014
      expect(@record.dirty).to eq({ 'year' => 2014 })
    end
  end

end
