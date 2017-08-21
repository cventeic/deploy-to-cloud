
# build: .
# command: bundle exec rails s -p 3000 -b '0.0.0.0'
docker_compose = <<-FOO
version: '2'
services:
  db:
    image: postgres
  web:
    build:            # Configuration options that are applied at build time.
      context: .      # Path to the build context dir in local file system

    # todo
    #command: bundle exec rails s -p 3000 -b '0.0.0.0'   # Default command

    volumes:
      - .:/home/app/cvwebapp
      # Development mode.
      # Mount host's current working directory at /myapp in container's working image
      # Container executes app code from host's local directory contents for development.
      # Remove this volume for production mode

    ports:
      - "3000:3000"
      - "80:80"
    depends_on:
      - db
FOO

make_file("docker-compose.yml", docker_compose)


exec 'touch Gemfile.lock'

# Start the web service
#   Create the rails app with in the web service container
#   (WORKDIR is 'myapp' so rails new executes in myapp)
#
#  Note: Bash is needed because of RVM in passenger-docker
#
exec "docker-compose run web bash -lc 'rails new . --force --database=postgresql'"


# todo not sure about this.  Conficts with app:app
exec 'sudo chown -R $USER:$USER .'

exec 'docker-compose build'

exec 'docker-compose up'

exec "docker-compose run web bash -lc 'rake db:create"


