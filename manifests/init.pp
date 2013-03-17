# Class: nginx
#
# This module installs Nginx and its default configuration using rvm as the provider.
#
# Parameters:
#   $ruby_version
#       Ruby version to install.
#   $passenger_version
#      Passenger version to install.
#   $logdir
#      Nginx's log directory.
#   $installdir
#      Nginx's install directory.
#   $www
#      Base directory for
#   $user
#      Owner of `www` dir
#   $group
#      Group of `www` dir (user running nginx should belong to this group)
# Actions:
#
# Requires:
#    puppet-rvm
#
# Sample Usage:  include nginx
class nginx (
  $ruby_version      = 'ruby-1.9.3-p392',
  $passenger_version = '3.0.19',
  $logdir            = '/var/log/nginx',
  $installdir        = '/opt/nginx',
  $www               = '/var/www',
  $extra_opts        = '--with-ipv6',
  $user              = 'www-data',
  $group             = 'www-data',
) {

    $options = "--auto --auto-download  --prefix=${installdir} --with-http_ssl_module ${extra_opts}"

    include rvm
    
    if !defined( Package['libcurl4-openssl-dev'] ) {   package { 'libcurl4-openssl-dev': ensure => present } }

    rvm_system_ruby {
      $ruby_version:
        ensure      => 'present',
        default_use => true;
    }

    rvm_gem {
      "${ruby_version}/passenger":
        ensure => $passenger_version,
    }

    exec { 'create container':
      command => "mkdir -p ${www} && chown ${user}:${group} ${www}",
      unless  => "test -d ${www}",
      before  => Exec['nginx-install']
    }

    exec { 'nginx-install':
      command => "bash -l -i -c \"/usr/local/rvm/gems/${ruby_version}/bin/passenger-install-nginx-module ${options}\"",
      group   => 'root',
      unless  => "test -d ${installdir}",
      require => [ Package[$passenger_deps], Rvm_system_ruby[$ruby_version], Rvm_gem["${ruby_version}/passenger"]];
    }

    file { 'nginx-config':
      path    => "${installdir}/conf/nginx.conf",
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('nginx/nginx.conf.erb'),
      require => Exec['nginx-install'],
    }

    exec { 'create sites-conf':
      path    => ['/usr/bin','/bin'],
      unless  => "test -d  ${installdir}/conf/sites-available && test -d ${installdir}/conf/sites-enabled",
      command => "mkdir  ${installdir}/conf/sites-available && mkdir ${installdir}/conf/sites-enabled",
      require => Exec['nginx-install'],
    }

    file { 'nginx-service':
      path      => '/etc/init.d/nginx',
      owner     => 'root',
      group     => 'root',
      mode      => '0755',
      content   => template('nginx/nginx.init.erb'),
      require   => File['nginx-config'],
      subscribe => File['nginx-config'],
    }

    file { $logdir:
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0644'
    }

    service { 'nginx':
      ensure     => running,
      enable     => true,
      hasrestart => true,
      hasstatus  => true,
      subscribe  => File['nginx-config'],
      require    => [ File[$logdir], File['nginx-service']],
    }

}
