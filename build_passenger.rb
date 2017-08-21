
def passenger_prep(container_context_directory: '', app_types: [])

  webapp_conf = <<-CONF
    server {
      # Maps URI to this "server" block
      #   The URI is specified in the "Host" header block in HTTP request
      server_name web-app;

      #listen 80;
      listen 8080;


      # The following deploys your Ruby/Python/Node.js/Meteor app on Passenger.

      # Not familiar with Passenger, and used (G)Unicorn/Thin/Puma/pure Node before?
      # Yes, this is all you need to deploy on Passenger! All the reverse proxying,
      # socket setup, process management, etc are all taken care automatically for
      # you! Learn more at https://www.phusionpassenger.com/.
      passenger_enabled on;
      passenger_user app;
 CONF

  webapp_conf += %{
      root /home/app/web-app/public;

      # If this is a Ruby app, specify a Ruby version:
      passenger_ruby /usr/bin/ruby2.4;
   } if app_types.include?("rails")

  webapp_conf += %{
      passenger_startup_file server.js;
      passenger_app_type node;

      # The static assets are in `dist` instead, so tell Nginx about it.
      root /home/app/web-app/dist;

      # There is no `tmp` dir. No problem, we can tell Passenger
      # to look for restart.txt in root instead.
      passenger_restart_dir /home/app/tmp;

  } if app_types.include?("node")

  webapp_conf += "  }"

  make_file("#{container_context_directory}/web-app.conf", webapp_conf)

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
    passenger_app_env production;

    passenger_friendly_error_pages on;
  }

  make_file("#{container_context_directory}/00_app_env.conf", app_env_conf_00)

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

  make_file("#{container_context_directory}/rails-env.conf", rails_env_conf) if app_types.include?("rails")


=begin
  postgres_env_conf = <<-FOO
  env POSTGRES_PORT_5432_TCP_ADDR;
  env POSTGRES_PORT_5432_TCP_PORT;
  FOO

  make_file("#{container_context_directory}/postgres-env.conf", postgres_env_conf)
=end

  #make_file("#{container_context_directory}/gzip_max.conf", "gzip_comp_level 9;")

  #make_file("#{container_context_directory}/secret_key.conf", "env SECRET_KEY=123456;")
end

