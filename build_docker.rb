require './build_passenger'

=begin
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
=end

def docker_ignore(context_directory:'', app_directory:'')
  puts "#{__method__.to_s} enter"

  #  #{app_directory}/.bundle
  #  .bundle
  dockerignore = %{
    .git*
    .env*
    .dockerignore
    db/*.sqlite3
    db/*.sqlite3-journal
    log/*
    tmp/*
    Dockerfile
    README.rdoc
    #{app_directory}/log/*
    #{app_directory}/tmp/*
    #{app_directory}/.git*
    #{app_directory}/yarn-error.log
    #{app_directory}/.byebug_history
    #{app_directory}/db/*.sqlite3
    #{app_directory}/db/*.sqlite3-journal
   }

  #  #{app_directory}/public/packs/*
  #  #{app_directory}/node_modules/*
  #  #{app_directory}/config/secrets.yml.key

  make_file("#{context_directory}/.dockerignore", dockerignore)

  puts "#{__method__.to_s} exit"
end


def docker_ready_context_directory(app_name: '', app_source_directory: '')
  puts "#{__method__.to_s} enter"

  # Local directory used to create docker image
  docker_context_directory = "docker_context_#{app_name}"

  exec("rm -r -f #{docker_context_directory}")

  exec("mkdir -p #{docker_context_directory}")

  # Populate the docker context directory
  exec("rsync -ar #{app_source_directory}/ #{docker_context_directory}/#{app_name}/")

  docker_ignore(context_directory: docker_context_directory, app_directory: app_name)

  # bundle update
  # bundle exec rake assets:precompile

  puts "#{__method__.to_s} exit"

  return docker_context_directory
end

######################################################

# Tag the created image so it can be pushed into repo
def docker_tag_image_into_repository(local_image_url, docker_remote_registry_url)
  puts "#{__method__.to_s} enter"

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
  #exec  "docker tag venteicher-org localhost:5000/venteicher-org"
  exec "docker tag #{local_image_url} #{docker_remote_registry_url}/#{local_image_url}"

  puts "#{__method__.to_s} exit"
end



def docker_ready_dockerfile( app_directory: '', app_types: [])
  puts "#{__method__.to_s} enter"

  dockerfile = []

  # Base Image
  dockerfile += [
    %{
      FROM phusion/passenger-ruby24

      # Set correct environment variables.
      ENV HOME /root
      ENV RAILS_ENV production

      # Use baseimage-docker's init process.
      CMD ["/sbin/my_init"]
    }
  ]

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
    }
  ]

  dockerfile += [
    %{
      # Copy the Gemfile as well as the Gemfile.lock and install 
      # the RubyGems. This is a separate step so the dependencies 
      # will be cached unless changes to one of those two files 
      # are made.
      COPY #{app_directory}/Gemfile #{app_directory}/Gemfile.lock ./
      RUN gem install bundler && bundle install --jobs 20 --retry 5

    },
  ] if(app_types.include?("rails"))

  dockerfile += [
      "ADD #{app_directory} /home/app/web-app",
  ]

  dockerfile += [ "RUN chown -R app:app /home/app/web-app"] if(app_types.include?("passenger"))

  dockerfile += [
    %{
      # Precompile Rails assets
      RUN bundle exec rake assets:precompile
    },
  ] if( app_types.include?("rails") )

  #
  # Put this at the end so we can re-use the heavy stuff created earlier
  #

  dockerfile += [
    %{
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
      ADD 00_app_env.conf /etc/nginx/conf.d/00_app_env.conf
    }
  ]

  dockerfile += [
    %{
      ADD rails-env.conf  /etc/nginx/main.d/rails-env.conf
    },
  ] if( app_types.include?("rails") )

=begin
    %{
      # Using Redis
      # Opt-in for Redis if you're using the 'customizable' image.
      RUN /pd_build/redis.sh

      # Enable the Redis service.
      RUN rm -f /etc/service/redis/down
    }
=end


  puts "#{__method__.to_s} exit"

  return dockerfile.join("\n")
end


def docker_create_container_image( image_name: '', context_directory: '')
  puts "#{__method__.to_s} enter"

  # Build the docker image
  #
  # https://docs.docker.com/engine/reference/commandline/build
  # docker tag info: https://medium.com/@mccode/the-misunderstood-docker-tag-latest-af3babfd6375
  #
  exec [
    "docker --debug build",
    "--tag #{image_name}",                  # Rename an image (example 'whenry/fedora-jboss:v2.1')

    "--file #{context_directory}/Dockerfile",  # 1) Where to find docker file

    "#{context_directory}"                     # 2) Where to find context dir
  ].join(' ')

  puts "#{__method__.to_s} exit"

end
