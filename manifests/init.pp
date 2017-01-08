# Class: snapd
# ===========================
#
# This module installs and manages the snapd package/service for using snap
# packages on your system.
#
# Examples
# --------
#
# @example
#    class { 'snapd': }
#
# Authors
# -------
#
# Danny Roberts <danny@thefallenphoenix.net>
#
# Copyright
# ---------
#
# Copyright 2017 Danny Roberts
#
class snapd {

  package { 'snapd': }

  $service_name = $facts['os']['name'] ? {
    'Archlinux' => 'snapd.socket',
    default     => 'snapd'
  }

  service { $service_name:
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    subscribe  => Package['snapd']
  }

}
