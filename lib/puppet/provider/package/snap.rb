require 'puppet/provider/package'

# Super simple snap package provider
# todo: latest, update
Puppet::Type.type(:package).provide :snap, :parent => Puppet::Provider::Package do
  desc "Package management based on snap."

  confine :operatingsystem => :ubuntu
  commands :installer => "/usr/bin/snap"

  def self.instances
    instance_by_name.collect do |name|
      self.new(
        :name     => name,
        :provider => :snap,
        :ensure   => :installed
      )
    end
  end

  def self.instance_by_name
    Dir.entries("/snap/bin").find_all { |f|
      f =~ /\.pkg$/
    }.collect { |name|
      yield name if block_given?

      name
    }
  end

  def query
    Puppet::FileSystem.exist?("/snap/bin/#{@resource[:name]}") ? {:name => @resource[:name], :ensure => :present} : nil
  end

  def install
    installer "install", "--classic", @resource[:name]
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
    installer "refresh", @resource[:name]
  end
end
