require 'spec_helper'

describe Calatrava::AppBuilder do
  include Aruba::Api

  before(:each) do
    create_dir 'app'

    proj = double('current project', :config => double('cfg', :path => 'env.coffee'))
    Calatrava::Project.stub(:current).and_return(proj)
  end

  let(:manifest) { double('web mf',
                          :coffee_files => ['path/to/kernel.coffee', 'diff/path/shell.coffee'],
                          :js_files => ['path/to/kernel.js', 'diff/path/shell.js'],
                          :kernel_bootstrap => ['path/to/kernel.coffee'],
                          :kernel_bootstrap_js => ['path/to/kernel.js'],
                          :haml_files => ['diff/path/shell.haml']) }
  
  let(:app) { Calatrava::AppBuilder.new('app/build', manifest) }

  context '#coffee_files' do
    subject { app.coffee_files }
    
    it { should include 'path/to/kernel.coffee' }
    it { should include 'diff/path/shell.coffee' }
    it { should include 'env.coffee' }
    end

  context '#js_files' do
    subject { app.js_files }

    it { should include 'path/to/kernel.js' }
    it { should include 'diff/path/shell.js' }
  end

  context '#js_file' do
    subject { app.as_js_file('path/to/sample.coffee') }

    it { should == 'app/build/scripts/sample.js' }
  end

  context '#load_file' do
    subject { app.load_instructions.lines.to_a }
    
    it { should include 'build/scripts/kernel.js' }
    it { should_not include 'build/scripts/shell.js' }
  end

  context '#haml_files' do
    subject { app.haml_files }

    it { should include 'diff/path/shell.haml' }
  end
end
