
def docker_ignore()
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

def docker_tag_image_into_repository(image_url, docker_registry_url)

  # Create a tag TARGET_IMAGE that refers to SOURCE_IMAGE
  #
  # An image name is made up of slash-separated name components, optionally prefixed by a registry hostname.
  #
  # docker tag SOURCE_IMAGE[:TAG] TARGET_IMAGE[:TAG]
  #
  # Tag a local image with name “httpd” into the “fedora” repository with “version1.0”:
  #   docker tag httpd fedora/httpd:version1.0
  #
  #exec "docker tag #{image_url} #{docker_registry_url}/#{container_name}"
  #exec "docker tag #{image_url} #{docker_registry_url}/#{container_name}:latest"
end


def docker_create_container_image(container_name, docker_context_url)
  puts "#{__method__.to_s} enter"

  puts "container_name #{container_name}"

  exec("mkdir -p #{docker_context_url}")

  base_image = {}

  #########################################

  base_image[:passenger] =  %{
    FROM phusion/passenger-ruby24

    # Set correct environment variables.
    ENV HOME /root

    # Use baseimage-docker's init process.
    CMD ["/sbin/my_init"]
}

  base_image[:ruby] =  %{
    FROM ruby
    RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
  }

  base_image[:gce_ruby] = %{
    # The Google App Engine Ruby runtime is Debian Jessie with Ruby installed
    # and various os-level packages to allow installation of popular Ruby
    # gems. The source is on github at: https://github.com/GoogleCloudPlatform/ruby-docker
    FROM gcr.io/google_appengine/ruby
  }


  #########################################

  nginx = %{
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
  }

  #########################################

  passenger_redis = %{
    # Using Redis
    # Opt-in for Redis if you're using the 'customizable' image.
    RUN /pd_build/redis.sh

    # Enable the Redis service.
    RUN rm -f /etc/service/redis/down
    }

  #########################################

  dockerfile = [
    base_image[:ruby],

    # nginx,
    # passenger_redis,

   %{
      # Configure the main working directory. This is the base
      # directory used in any further RUN, COPY, and ENTRYPOINT
      # commands.
      RUN mkdir -p /myapp
      WORKDIR /myapp
    },
    #%{
    #  RUN mkdir -p /home/app/cvwebapp
    #  WORKDIR /home/app/cvwebapp
    #},
    %{
      # Copy the Gemfile as well as the Gemfile.lock and install 
      # the RubyGems. This is a separate step so the dependencies 
      # will be cached unless changes to one of those two files 
      # are made.
      COPY test-app-git/Gemfile test-app-git/Gemfile.lock ./
      RUN gem install bundler && bundle install --jobs 20 --retry 5
    },
    " ADD test-app-git  /myapp",
    # "ADD test-app-git  /home/app/cvwebapp",
    # "RUN chown -R app:app /home/app/cvwebapp",
    %{
      # Expose port 3000 to the Docker host, so we can access it 
      # from the outside.
      EXPOSE 3000
    },
    %{
      # Configure an entry point, so we don't need to specify 
      # "bundle exec" for each of our commands.
      ENTRYPOINT ["bundle", "exec"]
    },
    %{
      # The main command to run when the container starts. Also
      # tell the Rails dev server to bind to all interfaces by
      # default.
      CMD ["rails", "server", "-b", "0.0.0.0"]
    }
  ].join("\n")


  make_file("#{docker_context_url}/Dockerfile", dockerfile)

  # Note: Docker ignore can be put directly in app dir

  # Build the docker image
  #
  # https://docs.docker.com/engine/reference/commandline/build
  # docker tag info: https://medium.com/@mccode/the-misunderstood-docker-tag-latest-af3babfd6375
  #
  exec [ 
    "docker --debug build",
    "--tag #{container_name}",                  # Name and optionally a tag in the ‘name:tag’ format
    "--file #{docker_context_url}/Dockerfile",  # 1) Where to find docker file
    "#{docker_context_url}"                     # 2) Where to find context dir
  ].join(' ')
  puts "#{__method__.to_s} exit"


  # docker_tag_image_into_repository(container_name, docker_registry_url)

end
