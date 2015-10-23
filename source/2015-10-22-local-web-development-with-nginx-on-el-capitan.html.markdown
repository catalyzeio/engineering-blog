---
title: Local Web Development With NGINX on OSX El Capitan
date: 2015-10-22
author: anthony
author_full: Anthony Pleshek
author_alt:
tags: NGINX, local development, angular, angularjs
---

# Why?
I upgraded to El Capitan the other night, and everything was great until I started in on development the next morning. Much to my chagrin, my local Apache setup had somehow gotten mangled during the upgrade. Instead of looking into how to fix my Apache setup, I decided it would be more advantageous for me to switch over to using NGINX. We (Catalyze) have switched over to using NGINX instead of Apache for our web properties, and it just made sense to switch over my local setup to match.

# Background/What is this post actually going to cover?
This post will cover the process I went through to get my development environment set up appropriately on OSX El Capitan (10.11) using Homebrew to install NGINX for hosting static files. Most of the web projects at Catalyze use Angular, so there are some things in the configuration specific to hosting single page webapps.

## Installation and Preparation
### Install NGINX
I used Homebrew to install NGINX, which you can find instructions for installing [here](http://brew.sh/). It isn't required by any means, but it will probably make your development life a lot easier if you don't already have and use it.

Once you have Homebrew install, the main command needed here is `$ brew install nginx`. If you run into issues and previously had installed Homebrew, you may need to run `$ brew doctor` and fix any issues it notes.

### Make sure apache isn't running
One of the next things to do is to make sure Apache isn't running, otherwise NGINX won't be able to bind to port 80. I needed to run `$ sudo apachectl stop` to make sure Apache was stopped.

## Configuration
Here comes the fun bit: actually configuring NGINX to host your local files.

### Configure nginx
Open /usr/local/etc/nginx/nginx.conf in the text editor of your choosing. A commonly-accepted best practice is to make folders within the nginx directory called sites-available and sites-enabled, but since this is just for local development, we're going to put everything directly in the main configuration file.

```
# Put your OSX username here in place of EXAMPLE
# Unless you've done interesting things with your user's group, it's probably 'staff'
user  EXAMPLE staff;

worker_processes  1;

# Note: you may have to manually create this folder and file
error_log  /var/log/nginx/error.log;

events {
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;

    server {
    		# Listen on port 80 (normal http)
        listen 80;

        # The value of server_name can just be `localhost`,
        # but if you want a more contextual URL, make sure to add a row
        # in your /etc/hosts file like `127.0.0.1  example.local`
        server_name example.local;

        # This is the path to the project you want to host
        # Make sure there's an index file of some kind in the directory you're pointing to
        root /Users/example/my-web-project;

				# This bit tells nginx how to serve files that are in /css and /img
        # This is necessary since we're using Angular
        #  - if you aren't hosting any single page webapps, you probably won't need this
        location ~ ^/(css|img) {
          gzip_static on;

          # Don't cache anything
          expires -1;
          add_header Pragma "no-cache";
          add_header Cache-Control "no-store, no-cache, must-revalidate, post-check=0, pre-check=0";

          break;
        }

				# For everything that isn't in /css or /img
        location / {

					# This tells NGINX to first find and serve a file specified by the uri,
					# otherwise go to index.html.
          try_files $uri /index.html;

					# Don't cache anything
          expires -1;
          add_header Pragma "no-cache";
          add_header Cache-Control "no-store, no-cache, must-revalidate, post-check=0, pre-check=0";
        }
    }
}
```

### Start nginx to load the new configuration
`$ sudo nginx`

Note the use of `sudo` here; this command must be run as sudo because we specified a user in our configuration file.

### View your site in your browser
That's it! You should now be able to navigate to your local site in your browser.
