require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'
include RspecPuppetFacts

RSpec.configure do |c|
  c.after(:suite) do
    RSpec::Puppet::Coverage.report!(80)
  end
end
