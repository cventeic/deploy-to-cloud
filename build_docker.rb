require './build_passenger'

def docker_ignore(docker_registry_url)
  dockerignore = %{
    .git*
    .env*
    .dockerignore
    .bundle
    db/*.sqlite3
    db/*.sqlite3-journal
    log/*
    tmp/*
    Dockerfile
    README.rdoc
    venteicher-org/log/*
    venteicher-org/tmp/*
    venteicher-org/.git*
    venteicher-org/.bundle
    venteicher-org/yarn-error.log
    venteicher-org/.byebug_history
    venteicher-org/db/*.sqlite3
    venteicher-org/db/*.sqlite3-journal
   }

  #  venteicher-org/public/packs/*
  #  venteicher-org/node_modules/*
  #  venteicher-org/config/secrets.yml.key

  make_file("#{docker_registry_url}/.dockerignore", dockerignore)
end

def docker_tag_image_into_repository(image_url, docker_registry_url)

  # Create a tag TARGET_IMAGE that refers to SOURCE_IMAGE
  #
  # An image name is made up of slash-separated name components, optionally prefixed by a registry hostname.
  #
  # docker tag SOURCE_IMAGE[:TAG] TARGET_IMAGE[:TAG]
  #
  # Tag a local image with name “httpd” into the “fedora” repository with “version1.0”:
  #
  #   do: docker tag httpd fedora/httpd:version1.0
  #
  #
  #exec "docker tag #{image_url} #{docker_registry_url}/#{container_name}"
  #exec "docker tag #{image_url} #{docker_registry_url}/#{container_name}:latest"
end


def docker_create_container_image(
  image_uri,           # Image Name
  docker_context_url   # Where the files are located to crate the image from 
)
  puts "#{__method__.to_s} enter"

  puts "image uri / name #{image_uri}"

  docker_ignore(docker_context_url)

  passenger = true


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

  if(passenger)
    nginx = %{
    # **** NGINX *****

    # Enable NGINX
    # 
    RUN rm -f /etc/service/nginx/down

    # Add a virtual host entry (server block) by placing a .conf file 
    # in the directory /etc/nginx/sites-enable
    #

    RUN rm /etc/nginx/sites-enabled/default
    ADD web-app.conf /etc/nginx/sites-enabled/web-app.conf

    # Configure NGINX
    #
    # Files in main.d are included into the Nginx configuration's main context
    # Files in conf.d are included in the Nginx configuration's http context.
    #

    # ADD gzip_max.conf   /etc/nginx/conf.d/gzip_max.conf
    # ADD secret_key.conf /etc/nginx/main.d/secret_key.conf
    ADD rails-env.conf  /etc/nginx/main.d/rails-env.conf
    ADD 00_app_env.conf /etc/nginx/conf.d/00_app_env.conf
    }

    #########################################

    passenger_redis = %{
    # Using Redis
    # Opt-in for Redis if you're using the 'customizable' image.
    RUN /pd_build/redis.sh

    # Enable the Redis service.
    RUN rm -f /etc/service/redis/down
    }
  end

  #########################################

  dockerfile = []

  #dockerfile += [ base_image[:ruby] ]
  dockerfile  += [ base_image[:passenger] ] if(passenger)

  dockerfile += [
    %{
      # Install Yarn
      #
      RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
      RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
      RUN apt-get update && apt-get install yarn
    },
      %{
      # Install Nodejs version 7
      RUN curl -sL https://deb.nodesource.com/setup_7.x | bash -
      RUN apt-get install -y nodejs
    },
  ]

  dockerfile += [
      %{
      # Configure the main working directory. This is the base
      # directory used in any further RUN, COPY, and ENTRYPOINT
      # commands.
      RUN mkdir -p /home/app/web-app
      WORKDIR /home/app/web-app
    },
      %{
      # Copy the Gemfile as well as the Gemfile.lock and install 
      # the RubyGems. This is a separate step so the dependencies 
      # will be cached unless changes to one of those two files 
      # are made.
      COPY venteicher-org/Gemfile venteicher-org/Gemfile.lock ./
      RUN gem install bundler && bundle install --jobs 20 --retry 5

    },
      "ADD venteicher-org  /home/app/web-app",
  ]

  dockerfile += [ "RUN chown -R app:app /home/app/web-app"] if(passenger)

  dockerfile += [
    %{
      # Precompile Rails assets
      RUN bundle exec rake assets:precompile
    },
  ]

  dockerfile_non_passenger = [
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
  ]

  # Put this at the end so we can re-use the heavy stuff created earlier
  dockerfile += [
    nginx,
    # passenger_redis,
  ]

  dockerfie = dockerfile.join("\n")


  make_file("#{docker_context_url}/Dockerfile", dockerfile)

  ##############################
  # Create the required files
  passenger_prep(docker_context_url)


  # Note: Docker ignore can be put directly in app dir

  # Build the docker image
  #
  # https://docs.docker.com/engine/reference/commandline/build
  # docker tag info: https://medium.com/@mccode/the-misunderstood-docker-tag-latest-af3babfd6375
  #
  exec [ 
    "docker --debug build",
    "--tag #{image_uri}",                  # Rename an image (example 'whenry/fedora-jboss:v2.1')

    "--file #{docker_context_url}/Dockerfile",  # 1) Where to find docker file

    "#{docker_context_url}"                     # 2) Where to find context dir
  ].join(' ')
  puts "#{__method__.to_s} exit"


  #docker_tag_image_into_repository(image_uri, docker_context_url)

end
