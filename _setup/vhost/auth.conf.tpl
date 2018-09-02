upstream phpfpm {
    # for PHP-FPM running on port
    server 127.0.0.1:9000;

    # for PHP-FPM running on UNIX socket
    #server unix:/var/run/php/php7.2-fpm.sock;
}

# www redirect to http://
server {
    listen 80;
    server_name www.${AUTH_API_DOMAIN};
    return 301 ${DOLLAR}scheme://${AUTH_API_DOMAIN}${DOLLAR}request_uri;

    error_log /var/log/nginx/www.${AUTH_API_DOMAIN}_error.log;
    access_log /var/log/nginx/www.${AUTH_API_DOMAIN}_access.log;
}

server {
    listen 80;
    server_name ${AUTH_API_DOMAIN};
    root ${ROOT_PATH}/public;

    location / {
        try_files ${DOLLAR}uri /index.php${DOLLAR}is_args${DOLLAR}args;
    }

    # {{{ PROD
    location ~ ^/index\.php(/|${DOLLAR}) {
        fastcgi_pass phpfpm;
        fastcgi_split_path_info ^(.+\.php)(/.*)${DOLLAR};
        include fastcgi_params;

        fastcgi_param SCRIPT_FILENAME ${DOLLAR}realpath_root${DOLLAR}fastcgi_script_name;
        fastcgi_param DOCUMENT_ROOT ${DOLLAR}realpath_root;

        # Prevents URIs that include the front controller. This will 404:
        # http://domain.tld/app.php/some-path
        # Remove the internal directive to allow URIs like this
        internal;
    }
    # }}}

    # return 404 for all other php files not matching the front controller
    # this prevents access to other php files you don't want to be accessible.
    location ~ \.php${DOLLAR} {
      return 404;
    }

    location ~ \.yml${DOLLAR} {
      return 404;
    }

    location = /favicon.ico {
      log_not_found off;
    }

    error_log /var/log/nginx/${AUTH_API_DOMAIN}_error.log;
    access_log /var/log/nginx/${AUTH_API_DOMAIN}_access.log;
}