# Define: nginx::vhost
#
# Creates nginx virtual hosts
#
# Parameters:
#   $host
#       The title of the resource  is used as the host.
#   $port
#       Virtual host port
#   $root
#       Virtual host path
#   $create_root
#       True or false, allows to create the path for the virtual host
#   $rails
#       True or false, sets if the application is rails based or not.
#   $user
#       Owner of host directory
#   $group
#       Group of host directory
# Actions:
#       Creates a virtual host
#
# Requires:
#       nginx
#
# Sample Usage:
#
#  nginx::vhost { 'test':
#    sever_name =>  'blog.test.com'
# }
define nginx::vhost(
  $host      = $name,
  $port      = '80',
  $root      = "/var/www/${host}",
  $makeroot  = true,
  $rails     = false,
  $rails_env = 'production',
  $user      = 'www-data',
  $group     = 'www-data',
  $template  = '',
  $auth_basic_file = '',
){
  include nginx

  if $template != '' {
    $erb = "${template}"
  }else {
    $erb =  $rails ? {
      true     => 'nginx/vhost.rails.erb',
      default  => 'nginx/vhost.erb',
    }
  }

  if $makeroot{
    file { $root:
      ensure  => directory,
      owner   => $user,
      group   => $group,
      mode    => '0755',
      require => Class['nginx'],
    }
  }

  file { $host:
    ensure  => present,
    path    => "${nginx::installdir}/conf/sites-available/${host}",
    owner   => $user,
    group   => $group,
    mode    => '0644',
    content => template("${erb}"),
    require => Class['nginx'],
  }

  file { "${nginx::installdir}/conf/sites-enabled/${host}":
    ensure  => link,
    target  => "${nginx::installdir}/conf/sites-available/${host}",
    require => File[$host],
  }

  exec { "nginx ${host}":
    command => '/etc/init.d/nginx restart',
    require => File["${nginx::installdir}/conf/sites-enabled/${host}"],
  }

}
