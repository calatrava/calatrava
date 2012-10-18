require 'spec_helper'

describe Calatrava::IosApp do
  include Aruba::Api

  before(:each) do
    create_dir 'ios'

    proj = double('current project', :config => double('cfg', :path => 'env.coffee'))
    Calatrava::Project.stub(:current).and_return(proj)
  end

  let(:manifest) { double('web mf',
                          :coffee_files => ['path/to/kernel.coffee', 'diff/path/shell.coffee'],
                          :haml_files => ['diff/path/shell.haml']) }
  
  let(:app) { Calatrava::IosApp.new(current_dir, manifest) }

  context '#coffee_files' do
    subject { app.coffee_files }
    
    it { should include 'path/to/kernel.coffee' }
    it { should include 'diff/path/shell.coffee' }
    it { should include 'env.coffee' }
  end

  context '#haml_files' do
    subject { app.haml_files }

    it { should include 'diff/path/shell.haml' }
  end
end
