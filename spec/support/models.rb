Filemaker.registry['default'] = Filemaker::Server.new do |config|
  config.host         = 'example'
  config.account_name = 'account_name'
  config.password     = 'password'
end

class Candidate
  include Filemaker::Model
end

class User
  include Filemaker::Model
end

class Post
  include Filemaker::Model

  string :candidate_id, :email
end

class Job
  include Filemaker::Model

  database :jobs
  layout   :jobs

  string :status
  string :jdid, fm_name: 'JDID'
  date   :modify_date, fm_name: 'modify date'

end

class MyModel
  include Filemaker::Model

  database :candidates
  layout :profile

  string :name, :email, default: 'UNTITLED'
  string :candidate_id, fm_name: 'CA ID', identity: true
  date :created_at
  datetime :updated_at, fm_name: 'ModifiedDate'
  money :salary
  integer :age, fm_name: 'passage of time'

  belongs_to :candidate
  belongs_to :applicant, class_name: User, reference_key: :name
  has_many :posts
  has_many :posters, class_name: User, reference_key: :email
end
