describe Filemaker::Metadata::Field do
  let(:server) do
    Filemaker::Server.new do |config|
      config.host         = 'host'
      config.account_name = 'account_name'
      config.password     = 'password'
      config.ssl          = { verify: false }
    end
  end
  let(:xml) { import_xml_as_string('portal.xml') }
  let(:resultset) { Filemaker::Resultset.new(server, xml) }
  let(:field) { Filemaker::Metadata::Field.new({}, resultset) }

  context 'coercion' do
    it 'converts to nil for empty string' do
      allow(field).to receive(:data_type).and_return 'text'
      expect(field.raw_cast('')).to be_nil
    end

    it 'converts to nil for space string' do
      allow(field).to receive(:data_type).and_return 'text'
      expect(field.raw_cast('   ')).to be_nil
    end

    it 'converts to nil for nil' do
      allow(field).to receive(:data_type).and_return 'text'
      expect(field.raw_cast(nil)).to be_nil
    end

    it 'converts text to String' do
      allow(field).to receive(:data_type).and_return 'text'
      expect(field.raw_cast('some text value')).to be_a String
    end

    it 'converts number to BigDecimal' do
      allow(field).to receive(:data_type).and_return 'number'
      expect(field.raw_cast('100')).to be_a BigDecimal
    end

    it 'removes decimal mark in number' do
      allow(field).to receive(:data_type).and_return 'number'
      expect(field.raw_cast('49,028.39')).to be_a BigDecimal
      expect(field.raw_cast('49,028.39')).to eq 49_028.39
    end

    it 'removes dollar sign in number' do
      allow(field).to receive(:data_type).and_return 'number'
      expect(field.raw_cast('$49,028.39')).to be_a BigDecimal
      expect(field.raw_cast('$49,028.39')).to eq 49_028.39
    end

    it 'converts date to Date' do
      allow(field).to receive(:data_type).and_return 'date'
      expect(field.raw_cast('10/31/2014')).to be_a Date
    end

    it 'converts time to DateTime' do
      allow(field).to receive(:data_type).and_return 'time'
      expect(field.raw_cast('12:12:12')).to be_a DateTime
    end

    it 'converts timestamp to DateTime' do
      allow(field).to receive(:data_type).and_return 'timestamp'
      expect(field.raw_cast('10/31/2014 12:12:12')).to be_a DateTime
    end

    it 'converts container to URI' do
      allow(field).to receive(:data_type).and_return 'container'
      expect(field.raw_cast('/fmi/xml/cnt/1234jpg')).to be_a URI
      expect(field.raw_cast('/fmi/xml/cnt/1234jpg').to_s).to eq \
        'https://host/fmi/xml/cnt/1234jpg'
    end

    it 'converts container with existing http' do
      allow(field).to receive(:data_type).and_return 'container'
      expect(field.raw_cast('http://host/fmi/xml/cnt/1234jpg')).to be_a URI
      expect(field.raw_cast('http://host/fmi/xml/cnt/1234jpg').to_s).to eq \
        'http://host/fmi/xml/cnt/1234jpg'
    end
  end
end
