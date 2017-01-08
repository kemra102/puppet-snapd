require 'spec_helper'

describe 'snapd' do
  context 'with default values for all parameters' do
    let(:facts) { {:os => { :family => 'Debian', :name => 'Ubuntu' } } }

    it { is_expected.to compile }
    it { is_expected.to contain_class('snapd') }
    it { is_expected.to contain_package('snapd') }
    it { is_expected.to contain_service('snapd').with_ensure('running').with_enable(true).with_hasrestart(true).that_subscribes_to(['Package[snapd]']) }
  end
  context 'on Arch linux' do
    let(:facts) { {:os => { :family => 'Archlinux', :name => 'Archlinux' } } }

    it { is_expected.to compile }
    it { is_expected.to contain_class('snapd') }
    it { is_expected.to contain_package('snapd') }
    it { is_expected.to contain_service('snapd.socket').with_ensure('running').with_enable(true).with_hasrestart(true).that_subscribes_to(['Package[snapd]']) }
  end
end
