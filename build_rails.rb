
=begin
config_database_yml = <<-YML
development: &default
  adapter: postgresql
  encoding: unicode
  database: myapp_development
  pool: 5
  username: postgres
  password:
  host: db

test:
  <<: *default
  database: myapp_test
YML

config_database_yml = <<-FOO
development: &default
  adapter: postgresql
  encoding: unicode
  database: myapp_development
  pool: 5
  username: postgres
  password:
  host: db

test:
  <<: *default
  database: myapp_test
FOO

config_database_yml = <<-FOO
development:
  adapter: postgresql
  encoding: unicode
  database: myapp_development
  pool: 5
  username: postgres
  password:
  host: db

test:
  adapter: postgresql
  encoding: unicode
  database: myapp_test
  pool: 5
  username: postgres
  password:
  host: db
FOO

  make_file("config/database.yml", config_database_yml) 
=end


#####################################

gem_file = <<-FOO
source 'https://rubygems.org'
#gem 'rails', '5.0.0.1'
gem 'rails'
gem 'pg'
FOO

make_file("Gemfile", gem_file)

def rails_configure_db(dataset_id)

  # Cloud Storage
  #
  config_database_yml = <<-YML
default: &default
  dataset_id: #{dataset_id}

development:
  <<: *default

production:
  <<: *default

# Test configuration
test:
  # Datastore
  dataset_id: gcd-test-dataset-directory
  host: http://localhost:8080/
  # SQL
  adapter: sqlite3
  pool: 5
  timeout: 5000
  database: db/test.sqlite3
  YML

  make_file("config/database.yml", config_database_yml) 

end


def rails_configure_settings(project)

  config_settings_yml = <<-YML
default: &default
  project_id: #{project.id}
  oauth2:
    client_id: your-client-id
    client_secret: your-client-secret
  cloud_storage:
    bucket: #{project.gcs_bucket_name}
    access_key_id: #{project.access_key}
    secret_access_key: #{project.secret}

development:
  <<: *default

production:
  <<: *default
  YML

  make_file("config/settings.yml", config_settings_yml) 
end


# exec 'rails new . --force --database=postgresql'

