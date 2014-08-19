# Filemaker

[![Build Status](https://travis-ci.org/mech/filemaker-ruby.svg?branch=master)](https://travis-ci.org/mech/filemaker-ruby)

A Ruby wrapper to FileMaker XML API.

## Installation

Put this in your Gemfile and you are ready to go:

```
gem 'filemaker'
```

## Initializing the Server

Ensure you have Web Publishing Engine (XML Publishing) enabled. Please turn on SSL also or credential will not be protected.

Configuration for initializing a server:

* `host`
* `ssl` - `verify: false` if you are using FileMaker's unsigned certificate. You can also pass a hash which will be forwarded to Faraday directly like `ssl: { client_cert: '', client_key: '', ca_file: '', ca_path: '/path/to/certs', cert_store: '' }`. See [Setting up SSL certificates](https://github.com/lostisland/faraday/wiki/Setting-up-SSL-certificates)
* `account` - Please use `ENV` variable like `ENV['FILEMAKER_ACCOUNT']`
* `password` - Please use `ENV` variable like `ENV['FILEMAKER_PASSWORD']`

```ruby
server = Filemaker::Server.new do |config|
  config.host     = 'localhost'
  config.account  = ENV['FILEMAKER_ACCOUNT']
  config.password = ENV['FILEMAKER_PASSWORD']
  config.ssl      = { verify: false }
end

server.databases.all                   # Using -dbnames
server.database['candidates'].layouts  # Using -layoutnames and -db=candidates

api = server.db['candidates'].lay['profile']
api = server.database['candidates'].layout['profile']
```

Once you are able to grab the `api`, you are golden and can make request to read/write to FileMaker API.

## Using the API

`Filemaker::Api::QueryCommand` and `Filemaker::Api::QueryParameter` are the main modules to use the API.

`Filemaker::Api::QueryCommand` API:

* `api.find()` for `-find`
* `api.find_any()` for `-findany`
* `api.find_query()` for `-findquery`
* `api.new()` for `-new`
* `api.edit()` for `-edit`
* `api.delete()` for `-delete`

Most API will be smart enough to reject invalid query parameters if passed in incorrectly.

## Using Filemaker::Layout

If you want ActiveModel-like access with a decent query DSL like `where`, `find`, `all`, you can include `Filemaker::Layout` to your model. Your Rails form will work as well as JSON serialization.

```ruby
class Job
  include Filemaker::Layout

  server :default # Taken from filemaker.yml config file
  database :jobs
  layout :job

  string :title, :requirements
  datetime :created_at, :published_at

  validates :title, presence: true

  def as_json(options = {})
    options[:except] ||= [:created_at]
    super(options)
  end
end
```

```yml
# filemaker.yml

development:
  default:
    host: localhost
    ssl: true
```

## Query DSL

## Contributing

We welcome pull request with specs.

1. Fork it ( https://github.com/mech/filemaker-ruby/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

Do run `rubocop -D -f simple` before committing.
