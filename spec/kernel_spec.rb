require 'spec_helper'

require 'aruba/api'
require 'calatrava/kernel'

describe Kernel do
  include Aruba::Api

  before(:each) do
    create_dir 'kernel'
    create_dir 'kernel/app/mod1'
    create_dir 'kernel/app/mod2'
  end

  subject { Calatrava::Kernel.new(current_dir) }

  it 'should find the correct two modules' do
    subject.modules.should have(2).items
    subject.modules.should include('mod1')
    subject.modules.should include('mod2')
  end

  it 'should provide a single path to all the coffee files' do
    subject.coffee_path.should include "app/mod1:app/mod2"
  end

  describe 'plugins' do
    before(:each) do
      create_dir 'kernel/plugins'
      write_file 'kernel/plugins/plugin.one.coffee', ''
      write_file 'kernel/plugins/two.coffee', ''
    end

    it 'should find the two plugins' do
      subject.plugins.should have(2).items
      subject.plugins.should include('plugin.one.coffee')
      subject.plugins.should include('two.coffee')
    end

    it 'should include the plugins in the coffee path' do
      subject.coffee_path.should include 'plugins'
    end
  end

end
