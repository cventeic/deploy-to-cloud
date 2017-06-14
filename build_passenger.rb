

webapp_conf = <<-FOO
server {
  listen 80;
  server_name www.webapp.com;
  root /home/app/cvwebapp/public;

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
FOO

make_file("webapp.conf", webapp_conf)

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

app_env_conf_00 = <<-FOO
  passenger_app_env development;
FOO

make_file("00_app_env.conf", app_env_conf_00)


# ADD postgres-env.conf /etc/nginx/main.d/postgres-env.conf

=begin
postgres_env_conf = <<-FOO
env POSTGRES_PORT_5432_TCP_ADDR;
env POSTGRES_PORT_5432_TCP_PORT;
FOO

make_file("/etc/nginx/main.d/postgres-env.conf", postgres_env_conf)
=end


make_file("gzip_max.conf", "gzip_comp_level 9;")

# make_file("secret_key.conf", "env SECRET_KEY=123456;")
end


#######
