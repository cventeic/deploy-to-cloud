
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


# RUN ...commands to place your web app in /home/app/cvwebapp...
COPY . /home/app/cvwebapp

RUN chown -R app:app /home/app/cvwebapp

# Clean up APT when done. Here?? Really todo
# RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

  YML
end


dockerfile_google_container_engine = <<-YML

# The Google App Engine Ruby runtime is Debian Jessie with Ruby installed
# and various os-level packages to allow installation of popular Ruby
# gems. The source is on github at:
#   https://github.com/GoogleCloudPlatform/ruby-docker
# FROM gcr.io/google_appengine/ruby

FROM phusion/passenger-ruby24

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

RUN apt-get update -qq && apt-get install -y vim

# Install 2.2.3 if not already preinstalled by the base image
#    gem install -q --no-rdoc --no-ri bundler --version 1.11.2

# RUN cd /rbenv/plugins/ruby-build && \
#    git pull && \
#    rbenv install -s 2.2.5 && \
#    rbenv global 2.2.5 && \
#    gem install -q --no-rdoc --no-ri bundler

#ENV RBENV_VERSION 2.2.5

# install bundler
#RUN gem install bundler

WORKDIR /app

# Hack to make bundle updates faster
# Note test-app is created before docker image is created
#COPY Gemfile* /app/

# Install gems to /bundle
#RUN bundle install

# Copy the application files.
COPY . /app/


#RUN echo "gem 'foreman'" >> Gemfile
#RUN echo "gem 'foreman'" >> HelloWorld
#RUN echo "gem 'foreman'" > HelloWorld2

#RUN touch Gemfile.lock

# Install required gems.
#RUN bundle install --deployment --jobs 20 --retry 5 && rbenv rehash
#RUN bundle install  --jobs 20 --retry 5
#RUN rbenv rehash

# Set environment variables.
ENV RACK_ENV=production \
    RAILS_ENV=production \
    RAILS_SERVE_STATIC_FILES=true

# Run asset pipeline.
# RUN bundle exec rake assets:precompile

# Reset entrypoint to override base image.
ENTRYPOINT []

# Use foreman to start processes. $FORMATION will be set in the pod
# manifest. Formations are defined in Procfile.
#CMD bundle exec foreman start --formation "$FORMATION"

  YML


