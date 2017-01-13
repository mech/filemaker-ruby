describe Filemaker::Metadata::Field do
  let(:server) do
    Filemaker::Server.new do |config|
      config.host         = 'https://host'
      config.account_name = 'account_name'
      config.password     = 'password'
    end
  end
  let(:xml) { import_xml_as_string('portal.xml') }
  let(:resultset) { Filemaker::Resultset.new(server, xml) }
  let(:field) { Filemaker::Metadata::Field.new({}, resultset) }

  context 'coercion' do
    it 'converts to nil for empty string' do
      allow(field).to receive(:data_type).and_return 'text'
      expect(field.coerce('')).to be_nil
    end

    it 'converts to nil for space string' do
      allow(field).to receive(:data_type).and_return 'text'
      expect(field.coerce('   ')).to be_nil
    end

    it 'converts to nil for nil' do
      allow(field).to receive(:data_type).and_return 'text'
      expect(field.coerce(nil)).to be_nil
    end

    it 'converts text to String' do
      allow(field).to receive(:data_type).and_return 'text'
      expect(field.coerce('some text value')).to be_a String
    end

    it 'converts number to BigDecimal' do
      allow(field).to receive(:data_type).and_return 'number'
      expect(field.coerce('100')).to be_a BigDecimal
    end

    it 'removes decimal mark in number' do
      allow(field).to receive(:data_type).and_return 'number'
      expect(field.coerce('49,028.39')).to be_a BigDecimal
      expect(field.coerce('49,028.39')).to eq 49_028.39
    end

    it 'removes dollar sign in number' do
      allow(field).to receive(:data_type).and_return 'number'
      expect(field.coerce('$49,028.39')).to be_a BigDecimal
      expect(field.coerce('$49,028.39')).to eq 49_028.39
    end

    it 'converts date to Date' do
      allow(field).to receive(:data_type).and_return 'date'
      expect(field.coerce('10/31/2014')).to be_a Date
    end

    it 'converts time to DateTime' do
      allow(field).to receive(:data_type).and_return 'time'
      expect(field.coerce('12:12:12')).to be_a DateTime
    end

    it 'converts timestamp to DateTime' do
      allow(field).to receive(:data_type).and_return 'timestamp'
      expect(field.coerce('10/31/2014 12:12:12')).to be_a DateTime
    end

    it 'converts container to URI' do
      allow(field).to receive(:data_type).and_return 'container'
      expect(field.coerce('/fmi/xml/cnt/1234jpg')).to be_a URI
      expect(field.coerce('/fmi/xml/cnt/1234jpg').to_s).to eq \
        'https://host/fmi/xml/cnt/1234jpg'
    end
  end
end
