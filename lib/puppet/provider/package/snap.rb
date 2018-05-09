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
end
