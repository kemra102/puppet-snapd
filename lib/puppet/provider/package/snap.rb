require 'puppet/provider/package'
require 'shellwords'

# Super simple snap package provider
# todo: latest, update
Puppet::Type.type(:package).provide :snap, :parent => Puppet::Provider::Package do
  desc "Package management based on snap."

  confine :operatingsystem => [ :ubuntu, :debian ]
  commands :installer => "/usr/bin/snap"
  has_feature :purgeable
  has_feature :upgradeable
  has_feature :install_options
  has_feature :versionable

  def self.instances
    output = installer "list"
    lines = output.force_encoding("UTF-8").split("\n")
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

  def valid_channel?
    # gets all available channels for a given snap package
    channels = `snap info #{@resource[:name]} | nawk '/channels:/{flag=1; next} /installed:/{flag=0} flag' | sed 's/:.*//' | sed 's/ *//'`

    channels.each_line do |ch|
      if @resource[:ensure] == ch.tr("\n",'')
        return true
      end
    end

    return false
    
  end

  def install
    
    # checks if snap exists and suppresses error output if it does not
    `snap list #{@resource[:name]} 2> /dev/null`
     
    if not $?.success?

      # package is not installed
      if valid_channel?
        installer "install", @resource[:name],"--channel=#{@resource[:ensure]}"
      else
        install_options = @resource[:install_options] || ['--classic']
        args = install_options.push(@resource[:name])
        installer "install", *args
      end
    else

      installed = `snap info #{@resource[:name]} | grep 'tracking:' | sed 's/tracking: *//' | tr -d '\n'`
      if valid_channel? and @resource[:ensure] != installed
        installer "refresh", @resource[:name] ,"--channel=#{@resource[:ensure]}"
      end
    end
  end

  def purge
    installer "remove", @resource[:name]
  end

  def uninstall
    installer "remove", @resource[:name]
  end

  def latest
    output = installer "search", @resource[:name]
    lines = output.force_encoding("UTF-8").split("\n")
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
