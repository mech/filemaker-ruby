describe Filemaker::Api::QueryCommands::CompoundFind do

  context 'with hash' do
    it '{a: [1, 2]} to (q0);(q1)' do
      expect(Filemaker::Api::QueryCommands::CompoundFind.new(
        a: [1, 2]
      ).key_maps_string).to eq '(q0);(q1)'
    end

    it '{a: [1, 2, 3]} to (q0);(q1);(q2)' do
      expect(Filemaker::Api::QueryCommands::CompoundFind.new(
        a: [1, 2, 3]
      ).key_maps_string).to eq '(q0);(q1);(q2)'
    end

    it '{a: 1, b: 2} to (q0,q1)' do
      expect(Filemaker::Api::QueryCommands::CompoundFind.new(
        a: 1, b: 2
      ).key_maps_string).to eq '(q0,q1)'
    end

    it '{a: 1, b: 2} to (q0,q1)' do
      expect(Filemaker::Api::QueryCommands::CompoundFind.new(
        a: 1, b: 2
      ).key_maps_string).to eq '(q0,q1)'
    end

    it '{a: [1, 2], b: 2} to (q0,q2);(q1,q2)' do
      expect(Filemaker::Api::QueryCommands::CompoundFind.new(
        a: [1, 2], b: 1
      ).key_maps_string).to eq '(q0,q2);(q1,q2)'
    end

    it '{a: [1, 2], b: 2, c: 3} to (q0,q2,q3);(q1,q2,q3)' do
      expect(Filemaker::Api::QueryCommands::CompoundFind.new(
        a: [1, 2], b: 2, c: 3
      ).key_maps_string).to eq '(q0,q2,q3);(q1,q2,q3)'
    end

    it '{a: [1, 2], "-omit": true} to !(q0);!(q1)' do
      expect(Filemaker::Api::QueryCommands::CompoundFind.new(
        a: [1, 2], '-omit' => true
      ).key_maps_string).to eq '!(q0);!(q1)'
    end
  end

  context 'with array' do
    it '[{a: 1}, {b: 2}] to (q0);(q1)' do
      expect(Filemaker::Api::QueryCommands::CompoundFind.new(
        [{ a: 1 }, { b: 2 }]
      ).key_maps_string).to eq '(q0);(q1)'
    end

    it '[{a: 1, b: 2}, {c: 3}] to (q0,q1);(q2)' do
      expect(Filemaker::Api::QueryCommands::CompoundFind.new(
        [{ a: 1, b: 2 }, { c: 3 }]
      ).key_maps_string).to eq '(q0,q1);(q2)'
    end

    it '[{a: [1, 2, 3], b: 1}, {c: 4, "-omit" => true}] to
      (q0,q3);(q1,q3);(q2,q3);!(q4)' do

      expect(Filemaker::Api::QueryCommands::CompoundFind.new(
        [{ a: [1, 2, 3], b: 1 }, { c: 4, '-omit' => true }]
      ).key_maps_string).to eq '(q0,q3);(q1,q3);(q2,q3);!(q4)'
    end
  end

end
