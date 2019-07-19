# Filemaker

[![Build Status](https://travis-ci.org/mech/filemaker-ruby.svg?branch=master)](https://travis-ci.org/mech/filemaker-ruby)

A Ruby wrapper to FileMaker XML API.

![UML - just kidding](https://cdn.rawgit.com/mech/filemaker-ruby/df077526/diagram.svg)

## Installation

At your Gemfile:

```
gem 'filemaker'
```

## Initializing the Server

Ensure you have Web Publishing Engine (XML Publishing) enabled. Please turn on SSL or credential won't be protected. Remember to also set the "Extended Privileges" to: `fmxml`.

Configuration for initializing a server:

* `host` - IP or hostname
* `account` - Please use `ENV` variable like `ENV['FILEMAKER_ACCOUNT']`
* `password` - Please use `ENV` variable like `ENV['FILEMAKER_PASSWORD']`
* `ssl` - Use `{ verify: false }` if you are using FileMaker's unsigned certificate.
* `ssl_verifypeer` - Default to `false`
* `ssl_verifyhost` - Default to `0`
* `log` - A choice of `simple`, `curl` and `curl_auth`.

```ruby
server = Filemaker::Server.new do |config|
  config.host         = ENV['FILEMAKER_HOST']
  config.account_name = ENV['FILEMAKER_ACCOUNT_NAME']
  config.password     = ENV['FILEMAKER_PASSWORD']
  config.ssl          = { verify: false }
  config.log          = curl
end

server.databases.all                      # Using -dbnames
server.database['candidates'].layouts.all # Using -layoutnames and -db=candidates
server.database['candidates'].scripts.all # Using -scriptnames and -db=candidates

api = server.db['candidates'].lay['profile']
api = server.db['candidates']['profile']
api = server.database['candidates'].layout['profile']

api.find(...)
```

Once you are able to grab the `api`, you are golden and can make requests to read/write to FileMaker API.

## Using the API

`Filemaker::Api::QueryCommands` is the main modules to use the API.

* `api.find()` for `-find`
* `api.findany()` for `-findany`
* `api.findquery()` for `-findquery`
* `api.new()` for `-new`
* `api.edit()` for `-edit`
* `api.delete()` for `-delete`
* `api.dup()` for `-dup`
* `api.view()` for `-view`

Most API will be smart enough to reject invalid query parameters if passed in incorrectly.

## Using Filemaker::Model

If you want ActiveModel-like access with a decent query DSL like `where`, `find`, `in`, you can include `Filemaker::Model` to your model. Your Rails form will work as well as JSON serialization.

The following data type mappings can be used to register the fields:

* `string` - `Filemaker::Model::Types::Text`
* `text` - `Filemaker::Model::Types::Text`
* `integer` - `Filemaker::Model::Types::Integer`
* `number` - `Filemaker::Model::Types::BigDecimal`
* `money` - `Filemaker::Model::Types::BigDecimal`
* `date` - `Filemaker::Model::Types::Date`
* `datetime` - `Filemaker::Model::Types::Time`
* `email` - `Filemaker::Model::Types::Email`

You can create your own custom type by providing these 3 class methods:

* `__filemaker_cast_to_ruby_object`
* `__filemaker_serialize_for_update`
* `__filemaker_serialize_for_query`

And register it with:

```ruby
Filemaker::Model::Type.register(:fast_string, FastStringType)
```

If the field name has spaces, you can use `fm_name` to identify the real FileMaker field name.

```ruby
string :job_id, fm_name: 'JobOrderID', identity: true
```

You can also use 3 relations: `has_many`, `belongs_to` and `has_portal`.

`has_many` will refer to the model's own identity as the reference key while `belongs_to` will append `_id` for the reference key unless being overridden by `reference_key`.

```ruby
class Job
  include Filemaker::Model

  database :jobs
  layout :job

  paginates_per 50

  # Taken from filemaker.yml config file, default to :default
  # Only use registry if you have multiple FileMaker servers you want to connect
  registry :read_slave

  string   :job_id, fm_name: 'JobOrderID', identity: true
  string   :title, :requirements
  datetime :created_at
  datetime :published_at, fm_name: 'ModifiedDate'
  money    :salary

  validates :title, presence: true

  belongs_to :company
  has_many :applicants, class_name: 'JobApplication', reference_key: 'job_id'
end
```

```yml
# filemaker.yml

development:
  default:
    host: <%= ENV['FILEMAKER_HOSTNAME'] %>
    account_name: <%= ENV['FILEMAKER_ACCOUNT_NAME'] %>
    password: <%= ENV['FILEMAKER_PASSWORD'] %>
    ssl: true
    ssl_verifypeer: false
    ssl_verifyhost: 0
    log: curl

  read_slave:
    host: ...
    ssl: { verify: false }

production:
  default:
    host: example.com
    ssl: { ca_path: '/secret/path' }
```

## Writing Standalone script

```ruby
#!/usr/bin/env ruby

require 'bundler/setup'
Bundler.require

Filemaker.registry['default'] = Filemaker::Server.new do |config|
  config.host         = ENV['FILEMAKER_HOST']
  config.account_name = ENV['FILEMAKER_ACCOUNT_NAME']
  config.password     = ENV['FILEMAKER_PASSWORD']
end

class Invoice
  include Filemaker::Model

  string :invoice_id, identity: true
  date :paid_at
  money :amount
end

invoices = Invoice.where(paid_at: '2017')

invoices.each do |invoice|
  import_invoice_to_s3
end
```

## Query DSL

### Using -find

```ruby
Model.where(gender: 'male', age: '< 50')    # Default -lop=and
Model.where(gender: 'male').or(age: '< 50') # -lop=or
Model.where(gender: 'male').not(age: 40)    # age.op=neq

# Supply a block to configure additional options like
# -script, -script.prefind, -lay.response, etc
Model.where(gender: 'male').or(age: '< 50') do |option|
  option[:script] = ['RemoveDuplicates', 20]
end

Model.where(gender: 'male').or(name: 'Lee').not(age: '=40')

# DateTime range example
Model.where(timestamp: "10/17/2015 00:00:00...10/20/2015 23:59:59")

# Comparison operator

Model.equals(candidate_id: '123')         # { candidate_id: '=123' }
Model.contains(name: 'Chong')             # { name: '*Chong*' }
Model.begins_with(salary: '2000...4000')  # ??
Model.ends_with(name: 'Yong')             # { name: '*Yong' }
Model.gt(age: 20)
Model.gte(age: 20)
Model.lt(age: 20)
Model.lte(age: 20)
Model.not(name: 'Bob')
```

### Using -findquery

**OR** broadens the found set and **AND** narrows it

```ruby
# (q0);(q1)
# (Singapore) OR (Malaysia)
Model.in(nationality: %w[Singapore Malaysia])

# (q0,q1)
# (nationality AND age)
# Essentially the same as:
# Model.where(nationality: 'Singapore', age: 30)
Model.in(nationality: 'Singapore', age: 30)

# (q0);(q1);(q2);(q3)
Model.in({ nationality: %w[Singapore Malaysia] }, { age: [20, 30] })

# (q0,q2);(q1,q2)
# (Singapore AND male) OR (Malaysia AND male)
Model.in(nationality: %w[Singapore Malaysia], gender: 'male')

# !(q0);!(q1)
# NOT(Singapore) OR NOT(Malaysia)
Model.not_in(nationality: %w[Singapore Malaysia])

# !(q0,q1)
Model.not_in(name: 'Lee', age: '< 40')

# !(q0);!(q1)
# Must be within an array of hashes
Model.not_in([{ name: 'Lee' }, { age: '< 40' }])

# (q0);(q1);!(q2,q3)
Model.in(nationality: %w(Singapore Malaysia)).not_in(name: 'Lee', age: '< 40')
```

Note: It is vitally important that you get the order right for mixing in the use of `in` with `not_in`. Likely you will want to do an `in` first to be inclusive and later omit using `not_in`.

- [x] Please test the above query with real data to ensure correctness!
- [x] Please test the comparison operators with keyword as well as applied to value.
- [x] Test serialization of BigDecimal and other types.
- [x] Caching of relation models.
- [x] Dirty checking API for model.
- [ ] Test the order for `in` and `not_in` found set accuracy.

## Pagination

If you have [kaminari](https://github.com/amatsuda/kaminari) in your project's `Gemfile`, `Filemaker::Model` will use it to page through the returned collection.

```ruby
Job.where(title: 'admin').per(50) # default to page(1)
Job.where(title: 'admin').page(5) # default to per(25)
Job.where(title: 'admin').page(2).per(35)

# In your model, you can customize the per_page
class Job
  include Filemaker::Model

  database :jobs
  layout :job

  paginates_per 50
end

Job.per_page # => 50
```

## Tips

`Filemaker::Model` include `Filemaker::Model::Findable` which create `Criteria` and `execute()` to return `Filemaker::Resultset` to be built by `Filemaker::Model::Builder`.

## Credits

This project is heavily inspired by the following Filemaker Ruby effort and several other ORM gems.

* [Rfm](https://github.com/lardawge/rfm)
* [ginjo/rfm](https://github.com/ginjo/rfm)
* [mongoid](https://github.com/mongoid/mongoid)
* [origin](https://github.com/mongoid/origin)
* [elasticsearch-ruby](https://github.com/elasticsearch/elasticsearch-ruby)

## Contributing

We welcome pull request with specs.

1. Fork it ( https://github.com/mech/filemaker-ruby/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

Do run `rubocop -D -f simple` before committing.
