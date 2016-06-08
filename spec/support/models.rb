Filemaker.registry['default'] = Filemaker::Server.new do |config|
  config.host         = 'example.com'
  config.account_name = 'account_name'
  config.password     = 'password'
end

class Candidate
  include Filemaker::Model

  string :candidate_id
end

class User
  include Filemaker::Model

  string :name
  string :email
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

class Member
  include Filemaker::Model

  string :id, identity: true
end

class Manager
  include Filemaker::Model

  string :id, identity: true
  string :mg_id
end

class MyModel
  include Filemaker::Model

  database :candidates
  layout :profile

  belongs_to :candidate
  belongs_to :applicant, class_name: User, reference_key: :name
  belongs_to :member
  belongs_to :manager, source_key: :mg_id
  belongs_to :another_manager, class_name: Manager, source_key: :mg_id, reference_key: :candidate_id
  has_many :posts
  has_many :posters, class_name: User, reference_key: :email

  string :name, :email, default: 'UNTITLED'
  string :candidate_id, fm_name: 'CA ID', identity: true
  string :member_id
  string :manager_id
  date :created_at
  datetime :updated_at, fm_name: 'ModifiedDate'
  money :salary
  integer :age, fm_name: 'passage of time'
end

class Project
  include Filemaker::Model

  string :id, identity: true

  has_many :project_members, source_key: :project_id, reference_key: :id
end

class ProjectMember
  include Filemaker::Model

  string :member_id
  string :project_id
end
