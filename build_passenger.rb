
def passenger_prep(docker_context_url)

  webapp_conf = %{
    server {
      # Maps URI to this "server" block
      #   The URI is specified in the "Host" header block in HTTP request
      server_name web-app;

      #listen 80;
      listen 8080;

      root /home/app/web-app/public;

      # The following deploys your Ruby/Python/Node.js/Meteor app on Passenger.

      # Not familiar with Passenger, and used (G)Unicorn/Thin/Puma/pure Node before?
      # Yes, this is all you need to deploy on Passenger! All the reverse proxying,
      # socket setup, process management, etc are all taken care automatically for
      # you! Learn more at https://www.phusionpassenger.com/.
      passenger_enabled on;
      passenger_user app;

      # If this is a Ruby app, specify a Ruby version:
      passenger_ruby /usr/bin/ruby2.4;
    }
  }

  make_file("#{docker_context_url}/web-app.conf", webapp_conf)

  ########

  # Setting environment variables in Nginx
  #
  # Overriding Environment Values is tricky
  #
  # By default Nginx clears all environment variables (except TZ) for its child processes
  #   (Passenger being one of them). 
  #
  # That's why any environment variables you set with docker run -e, 
  #   Docker linking and /etc/container_environment, won't reach Nginx.
  #
  # To preserve variables, place an Nginx config file ending with *.conf in the directory /etc/nginx/main.d, 
  #   in which you tell Nginx to preserve these variables. 
  #

  # ADD 00_app_env.conf /etc/nginx/conf.d/00_app_env.conf

  #  passenger_app_env development;
  #  passenger_app_env production;

  app_env_conf_00 = %{
    passenger_app_env development;

    passenger_friendly_error_pages on;
  }

  make_file("#{docker_context_url}/00_app_env.conf", app_env_conf_00)

  # ADD postgres-env.conf /etc/nginx/main.d/postgres-env.conf

  rails_env_conf = %{
    # rails-env.conf
    
    # Environment values to pass through

    # Set Nginx config environment based on
    # the values set in the .env file
    #env SECRET_KEY_BASE;
    env RAILS_MASTER_KEY;
    env RAILS_ENV;
  }

  make_file("#{docker_context_url}/rails-env.conf", rails_env_conf)


=begin
  postgres_env_conf = <<-FOO
  env POSTGRES_PORT_5432_TCP_ADDR;
  env POSTGRES_PORT_5432_TCP_PORT;
  FOO

  make_file("#{docker_context_url}/postgres-env.conf", postgres_env_conf)
=end

  #make_file("#{docker_context_url}/gzip_max.conf", "gzip_comp_level 9;")

  #make_file("#{docker_context_url}/secret_key.conf", "env SECRET_KEY=123456;")
end

