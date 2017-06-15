
def docker_create_container_image(container_name)
  puts "#{__method__.to_s} enter"

  dockerfile_google_container_engine = <<-YML

# The Google App Engine Ruby runtime is Debian Jessie with Ruby installed
# and various os-level packages to allow installation of popular Ruby
# gems. The source is on github at:
#   https://github.com/GoogleCloudPlatform/ruby-docker
FROM gcr.io/google_appengine/ruby

# Install 2.2.3 if not already preinstalled by the base image
#    gem install -q --no-rdoc --no-ri bundler --version 1.11.2
RUN cd /rbenv/plugins/ruby-build && \
    git pull && \
    rbenv install -s 2.2.5 && \
    rbenv global 2.2.5 && \
    gem install -q --no-rdoc --no-ri bundler \
    gem install -q --no-rdoc --no-ri foreman
ENV RBENV_VERSION 2.2.5

# Copy the application files.
COPY . /app/


# Install required gems.
RUN bundle install --deployment && rbenv rehash

# Set environment variables.
ENV RACK_ENV=production \
    RAILS_ENV=production \
    RAILS_SERVE_STATIC_FILES=true

# Run asset pipeline.
RUN bundle exec rake assets:precompile

# Reset entrypoint to override base image.
ENTRYPOINT []

# Use foreman to start processes. $FORMATION will be set in the pod
# manifest. Formations are defined in Procfile.
CMD bundle exec foreman start --formation "$FORMATION"

  YML

  make_file("test-app/Dockerfile", dockerfile_google_container_engine )

  #exec 'docker run web rails new . --force --database=postgresql'
  #exec 'docker run web rails new . --force '


  # Not target here is gcr
  #
  #exec "docker build --verbose -t gcr.io/#{project.id}/#{project.name}:#{project.container_name}"
  puts "container_name #{container_name}"
  exec "docker build -t #{container_name} test-app"

  # https://docs.docker.com/registry/#requirements

  #external_registry_endpoint = "localhost:5000/"
	#exec "docker tag #{container_name} #{container_name} #{external_registry_endpoint}#{container_name}:#{container_name}"

	#exec "docker tag #{container_name} #{container_name} #{external_registry_endpoint}#{container_name}:latest"

	#exec "docker tag #{container_name} #{external_registry_endpoint}#{container_name}/#{container_name}"
	#exec "docker tag #{container_name} #{external_registry_endpoint}#{container_name}/#{container_name}:latest"


  puts "#{__method__.to_s} exit"
end




def abcd()
  dockerfile = <<-YML
FROM phusion/passenger-ruby24

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]


# **** NGINX *****

# Enable NGINX
# 
RUN rm -f /etc/service/nginx/down

# Add a virtual host entry (server block) by placing a .conf file 
# in the directory /etc/nginx/sites-enable
#

RUN rm /etc/nginx/sites-enabled/default
ADD webapp.conf /etc/nginx/sites-enabled/webapp.conf

# Configure NGINX
#
# Files in main.d are included into the Nginx configuration's main context
# Files in conf.d are included in the Nginx configuration's http context.
#

ADD secret_key.conf  /etc/nginx/main.d/secret_key.conf
ADD gzip_max.conf    /etc/nginx/conf.d/gzip_max.conf
ADD 00_app_env.conf /etc/nginx/conf.d/00_app_env.conf

# ADD rails-env.conf /etc/nginx/main.d/rails-env.conf

# **** *****

# Using Redis
# Opt-in for Redis if you're using the 'customizable' image.
# RUN /pd_build/redis.sh

# Enable the Redis service.
# RUN rm -f /etc/service/redis/down

# **** *****

# **** *****

RUN mkdir /home/app/cvwebapp
WORKDIR /home/app/cvwebapp

# Copy the Gemfile as well as the Gemfile.lock and install the RubyGems. 
# This is a separate step so the dependencies will be cached 
# unless changes to one of those two files are made.
# 
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install --jobs 20 --retry 5

# Run bundle install in /myapp directory in image
#RUN bundle install # run bundle install in /myapp directory in image

# RUN ...commands to place your web app in /home/app/cvwebapp...
COPY . /home/app/cvwebapp

RUN chown -R app:app /home/app/cvwebapp

# Clean up APT when done. Here?? Really todo
# RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

  YML
  dockerignore = <<-FOO
.git*
db/*.sqlite3
db/*.sqlite3-journal
log/*
tmp/*
Dockerfile
README.rdoc
  FOO

  make_file(".dockerignore", dockerignore)
end


