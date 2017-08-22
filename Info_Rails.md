# Rails

## Secrets
deploy.rb automatially sets this up.

Prep Secrets:

  - Rails 4.1 introduced secrets.yml. The default file has secret_key_base.
    You can also store access keys to external APIs, http basic login and other sensitive credentials.

    development:
      secret_key_base: 3b7cd727ee24e8444053437c36cc66c3
      some_api_key: SOMEKEY

  - Rails 5 introduced encrypted version of secrets.yml for use in production

    Secretive secrets are not enabled by default. Turn them on with:
      rails secrets:setup

    The file config/secrets.yml.enc is like a little encrypted database of secrets that you can safely commit with the rest of your source code.

    To edit it:
      EDITOR=vim bin/rails secrets:edit  

### RAILS_MASTER_KEY / base64

Seems like kubernetes requires keys to be encoded in base64 in secret file and
auto decodes the keys on read back to original

See https://kubernetes.io/docs/concepts/configuration/secret/


## Production
RAILS_ENV=production RAILS_SERVE_STATIC_FILES=true bundle exec rails s

Static files (javascript, etc) are normally served by NGINX in production mode.
For testing production mode you need to set RAILS_SERVER_STATIC_FILES so rails
server / puma will actually serve the static files

For optimization See: http://edgeguides.rubyonrails.org/asset_pipeline.html


### 5.6 X-Sendfile Headers
The X-Sendfile header is a directive to the web server to ignore the response from the application, and instead serve a specified file from disk.
This option is off by default, but can be enabled if your server supports it.
When enabled, this passes responsibility for serving the file to the web server, which is faster.
Have a look at send_file on how to use this feature.

Apache and NGINX support this option, which can be enabled in config/environments/production.rb:

  config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
  config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

### 4.1.1 Far-future Expires Header

Precompiled assets exist on the file system and are served directly by your web server. 
They do not have far-future headers by default, so to get the benefit of fingerprinting you'll have to update your server configuration to add those headers.

For NGINX:

location ~ ^/assets/ {
  expires 1y;
  add_header Cache-Control public;

  add_header ETag "";
}

## Creation

rails new test-app-git --database=postgresql --webpack=angular
bundle exec rails webpacker:install  # This is needed to actually install bin/webpacker etc
bundle exec rake webpacker:install:angular

bundle exec rake yarn:install  # Install everything in package.json

hot reaload of javascript assets as they are modified
./bin/webpack-dev-server --hot --host 127.0.0.1

## Setup angular html templates and css to pull from angular dirs in Rails

https://github.com/rails/webpacker#use-html-templates-with-typescript-and-angular

yarn add html-loader
yarn add css-loader
yarn add to-string-loader

https://github.com/webpack-contrib/css-loader

gist: need to set up webpacker to pull content from right place

    import { Component } from '@angular/core';
    import { Http } from '@angular/http';
    import templateString from './app.component.html';
    import cssContent from './app.component.css';

    //console.log('CSS file contents: ', cssString.toString());

    @Component({
      selector: 'app-root',
      template: templateString,
      styles: [ cssContent.toString() ]
    })

    export class AppComponent {
      myData: Array<any>;
      constructor (private http:Http){
        this.http.get('https://jsonplaceholder.typicode.com/photos')
          .map(response => response.json())
          .subscribe(res => this.myData = res);
      }
    }




