describe Filemaker::Layout do
  it 'presets -db and -lay' do
    database = Filemaker::Database.new('candidates', double)
    layout = Filemaker::Layout.new('profile', double, database)
    expected_params = { '-db' => 'candidates', '-lay' => 'profile' }
    expect(layout.default_params).to eq expected_params
  end

  context 'api' do
    before do
      @server = Filemaker::Server.new do |config|
        config.host         = 'example.com'
        config.account_name = 'account_name'
        config.password     = 'password'
      end

      fake_typhoeus_post('employment.xml')
      @layout = @server.db['candidates']['Profile']
    end

    describe 'findany' do
      it 'finds a random record' do
        resultset = @layout.findany
        expect(resultset.params).to have_key('-findany')
        expect(resultset.params['-db']).to eq 'candidates'
        expect(resultset.params['-lay']).to eq 'Profile'
        expect(resultset.params['-findany']).to eq ''
      end

      it 'ignores -skip, -max' do
        resultset = @layout.findany(max: 1, skip: 2)
        expect(resultset.params).to_not have_key('-max')
        expect(resultset.params).to_not have_key('-skip')
      end
    end

    describe 'findall' do
      it 'finds all records' do
        resultset = @layout.findall
        expect(resultset.params).to have_key('-findall')
        expect(resultset.params['-db']).to eq 'candidates'
        expect(resultset.params['-lay']).to eq 'Profile'
        expect(resultset.params['-findall']).to eq ''
      end

      it 'allows -max, -skip' do
        resultset = @layout.findall(
          max: 5, skip: 10,
          sortfield: %w[f1 f2], sortorder: ['descend']
        )

        expect(resultset.params['-max']).to eq 5
        expect(resultset.params['-skip']).to eq 10
        expect(resultset.params['-sortfield.1']).to eq 'f1'
        expect(resultset.params['-sortfield.2']).to eq 'f2'
        expect(resultset.params['-sortorder.1']).to eq 'descend'
        expect(resultset.params['-sortorder.2']).to eq 'ascend'
      end

      it 'will not accept more than 9 sortfields' do
        expect do
          @layout.findall(
            sortfield: %w[f1 f2 f3 f4 f5 f6 f7 f8 f9 f10],
            sortorder: %w[o1 o2 o3 o4 o5 o6 o7 o8 o9]
          )
        end.to raise_error Filemaker::Errors::ParameterError
      end

      it 'will not accept more than 9 sortorders' do
        expect do
          @layout.findall(
            sortfield: %w[f1 f2 f3 f4 f5 f6 f7 f8 f9],
            sortorder: %w[o1 o2 o3 o4 o5 o6 o7 o8 o9 o10]
          )
        end.to raise_error Filemaker::Errors::ParameterError
      end
    end

    describe 'find' do
      it 'finds a single record using -recid' do
        resultset = @layout.find(1)
        expect(resultset.params).to have_key('-find')
        expect(resultset.params['-db']).to eq 'candidates'
        expect(resultset.params['-lay']).to eq 'Profile'
        expect(resultset.params['-find']).to eq ''
        expect(resultset.params['-recid']).to eq '1'
      end

      it 'finds some records with criteria' do
        args = { name: 'Bob', day: Date.parse('25/8/2014') }
        resultset = @layout.find(args, max: 1)
        expect(resultset.params['name']).to eq 'Bob'
        expect(resultset.params['day']).to eq '08/25/2014'
        expect(resultset.params['-max']).to eq 1
      end

      it 'switches layout for response' do
        resultset = @layout.find({}, lay_response: 'my_layout')
        expect(resultset.params['-lay.response']).to eq 'my_layout'
      end

      it 'OR the query' do
        resultset = @layout.find({}, lop: 'or')
        expect(resultset.params['-lop']).to eq 'or'
      end
    end

    describe 'delete' do
      it 'deletes a record' do
        resultset = @layout.delete(1)
        expect(resultset.params).to have_key('-delete')
        expect(resultset.params['-db']).to eq 'candidates'
        expect(resultset.params['-lay']).to eq 'Profile'
        expect(resultset.params['-delete']).to eq ''
        expect(resultset.params['-recid']).to eq '1'
      end
    end

    describe 'edit' do
      it 'edits a record' do
        resultset = @layout.edit(123, { first_name: 'Bob' }, modid: 55)
        expect(resultset.params).to have_key('-edit')
        expect(resultset.params['-db']).to eq 'candidates'
        expect(resultset.params['-lay']).to eq 'Profile'
        expect(resultset.params['-edit']).to eq ''
        expect(resultset.params['-recid']).to eq '123'
        expect(resultset.params['first_name']).to eq 'Bob'
        expect(resultset.params['-modid']).to eq 55
      end

      it 'filters layout relatedset and returns all portal records' do
        args = { first_name: 'Bob' }
        options = { relatedsets_filter: 'layout', relatedsets_max: 'all' }
        resultset = @layout.edit(123, args, options)
        expect(resultset.params['-relatedsets.filter']).to eq 'layout'
        expect(resultset.params['-relatedsets.max']).to eq 'all'
      end

      it 'deletes a portal record using -edit' do
        resultset = @layout.edit(123, {}, delete_related: 'jobtable.20')
        expect(resultset.params['-delete.related']).to eq 'jobtable.20'
      end
    end

    describe 'new' do
      it 'adds a new record' do
        resultset = @layout.new({ first_name: 'Bob' })
        expect(resultset.params).to have_key('-new')
        expect(resultset.params['-db']).to eq 'candidates'
        expect(resultset.params['-lay']).to eq 'Profile'
        expect(resultset.params['-new']).to eq ''
        expect(resultset.params['first_name']).to eq 'Bob'
      end
    end

    describe 'dup' do
      it 'duplicates a record' do
        resultset = @layout.dup(123)
        expect(resultset.params).to have_key('-dup')
        expect(resultset.params['-db']).to eq 'candidates'
        expect(resultset.params['-lay']).to eq 'Profile'
        expect(resultset.params['-dup']).to eq ''
        expect(resultset.params['-recid']).to eq '123'
      end
    end

    describe 'view' do
      it 'retrieves layout information with zero record' do
        resultset = @layout.view
        expect(resultset.params).to have_key('-view')
        expect(resultset.params['-view']).to eq ''
      end
    end

    describe 'query' do
      it 'transform {a: [1,2]} to (q0);(q1)' do
        resultset = @layout.query(status: %w[open closed])
        expect(resultset.params['-query']).to eq '(q0);(q1)'
      end

      it 'transforms [{a:1, b:2}, {c:3}, {d:4}, {e:5, "-omit": true}] to \
        (q0,q1);(q2);(q3);!(q4)' do
        resultset = @layout.query(
          [{ a: 1, b: 2 }, { c: 3 }, { d: 4 }, { e: 5, '-omit' => true }]
        )
        expect(resultset.params['-query']).to eq '(q0,q1);(q2);(q3);!(q4)'
      end
    end

    context 'script, prefind, and presort' do
      it 'can do -script' do
        resultset = @layout.find(1, script: 'Remove Duplicates')
        expect(resultset.params['-script']).to eq 'Remove Duplicates'
      end

      it 'can do -script.param' do
        resultset = @layout.find(1, script: ['Remove Duplicates', 'reverse'])
        expect(resultset.params['-script']).to eq 'Remove Duplicates'
        expect(resultset.params['-script.param']).to eq 'reverse'
      end

      it 'can do -script.prefind' do
        resultset = @layout.find(1, script_prefind: 'Unique')
        expect(resultset.params['-script.prefind']).to eq 'Unique'
      end

      it 'can do -script.prefind.param' do
        resultset = @layout.find(1, script_prefind: %w[Unique yes])
        expect(resultset.params['-script.prefind']).to eq 'Unique'
        expect(resultset.params['-script.prefind.param']).to eq 'yes'
      end

      it 'can do -script.presort' do
        resultset = @layout.find(1, script_presort: 'Order')
        expect(resultset.params['-script.presort']).to eq 'Order'
      end

      it 'can do -script.presort.param' do
        resultset = @layout.find(1, script_presort: %w[Order ascend])
        expect(resultset.params['-script.presort']).to eq 'Order'
        expect(resultset.params['-script.presort.param']).to eq 'ascend'
      end
    end
  end
end
