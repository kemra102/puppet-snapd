require 'puppet/provider/package'

# Super simple snap package provider
# todo: latest, update
Puppet::Type.type(:package).provide :snap, :parent => Puppet::Provider::Package do
  desc "Package management based on snap."

  confine :operatingsystem => :ubuntu
  commands :installer => "/usr/bin/snap"
  has_feature :purgeable
  has_feature :upgradeable
  has_feature :install_options

  def self.instances
    output = installer "list"
    lines = output.split("\n")
    lines.shift # skip header
    instances = []

    lines.each { |line|
      unless line =~ /^(\S+)\s+(\S+)\s+(.+)$/
        raise Puppet::Error.new(line + " does not contain a version", 1)
      end

      name = $1
      version = $2

      instances << self.new(
        :name     => name,
        :provider => :snap,
        :ensure   => version
      )
    }

    instances
  end

  def query
    instances = self.class.instances
    instances.each { |instance|
      if instance.name == @resource[:name]
        return instance
      end
    }

    nil
  end

  def install
    install_options = @resource[:install_options] || ['--classic']
    args = install_options.push(@resource[:name])
    installer "install", *args
  end

  def purge
    installer "remove", @resource[:name]
  end

  def uninstall
    installer "remove", @resource[:name]
  end

  def latest
    output = installer "search", @resource[:name]
    lines = output.split("\n")
    lines.shift # skip header

    lines.each { |line|
      unless line =~ /^(\S+)\s+(\S+)\s+(.+)$/
        raise Puppet::Error.new(line + " does not contain a version", 1)
      end

      name = $1
      version = $2
      info = $3

      if name == @resource[:name]
        return version
      end
    }
  end

  def update
    unless self.query
      return self.install
    end

    installer "refresh", @resource[:name]
  end
end
