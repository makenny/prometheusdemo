#

#
class profile::monitoring (
  Boolean $server = false,
){

  notify { "${module_name} monitoring":
    message  => 'applied',
    loglevel => 'info',
  }

  if $server {
    include profile::monitoring::server
  } else {
    include profile::monitoring::client
  }

}
