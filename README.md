## Puppet Nginx Module

This is a fork of [puppet-nginx](https://bitbucket.org/sgmac/puppet-nginx) to install [nginx](http://nginx.org/) with [passenger](https://www.phusionpassenger.com/) using default Ruby version. Nginx is fetched from nginx website and compiled with extra parameters you specify. 

### Requires

  - [puppet-rvm](https://github.com/blt04/puppet-rvm)
  - Puppet 2.6.17 (or higher)

Nginx is installed with usage of [puppet-rvm](https://github.com/blt04/puppet-rvm). Please, read the documentation before you begin. 

### Basic usage

Install nginx with

```
include nginx
```

or with parametrized class:

```
class { 'nginx': }
```

By default installs on _/opt/nginx_, there are some variables you might override

```
$ruby_version      = 'ruby-1.9.3-p392'
$passenger_version = '3.0.19'
$version           = '1.2.7'          # nginx version
$installdir	       = '/opt/nginx'
$logdir	           = '/var/log/nginx'
$www               = '/var/www'
```
A custom installation might look like this:

``` 
node webserver { 
    class { 'nginx':
      ruby_version      => 'ruby-1.9.3-p392',
      passenger_version => '3.0.19',
      www               => '/var/www',
      installdir        => '/usr/local/nginx',
   	  logdir            => '/usr/local/logs/nginx',
      extra_opts        => '--with-ipv6 --with-http_ssl_module',
      user              => 'www-data', # user owning www folder
    }
}
```

### Virtual Hosts

You can easily configure a virtual hosts. An example is:

```
nginx::vhost { 'www.example.com':
	port      => '8080',
	rails     => true,
  rails_env => 'production',
  root      => '/var/www/example',
}
```
The _rails_ attribute is optional and set to false by default. However, if you want to deploy a rails app, use this attribute and the rails template will be used instead.

### Supported systems

This module has been tested on:

  - Debian Squeeze 6.0.5, Puppet 3.1.0


For custom types, do not forget to enable pluginsync:

```
[main]
pluginsync = true

```



### MIT License 

Copyright (C) 2012 by Sergio Galván

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
