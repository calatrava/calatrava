require 'spec_helper'

describe Calatrava::AppBuilder do
  include Aruba::Api

  before(:each) do
    create_dir 'app'

    proj = double('current project', :config => double('cfg', :path => 'env.coffee'))
    allow(Calatrava::Project).to receive(:current).and_return(proj)
  end

  let(:manifest) { double('web mf',
                          :coffee_files => ['path/to/kernel.coffee', 'diff/path/shell.coffee'],
                          :kernel_bootstrap => ['path/to/kernel.coffee'],
                          :haml_files => ['diff/path/shell.haml'],
                          :kernel_libraries => ['path/to/external/kernel_lib.js']) }
  
  let(:app) { Calatrava::AppBuilder.new('app', 'app/build', manifest) }

  context '#coffee_files' do
    subject { app.coffee_files.collect { |cf| cf.source_file.to_s } }
    
    it { is_expected.to include 'path/to/kernel.coffee' }
    it { is_expected.to include 'diff/path/shell.coffee' }
    it { is_expected.to include 'env.coffee' }
  end

  context '#js_file' do
    subject { app.js_file('path/to/sample.coffee') }

    it { is_expected.to eq('app/build/scripts/sample.js') }
  end

  context '#load_file' do
    subject { app.load_instructions.lines.to_a.each(&:chomp!) }
    
    it { is_expected.to include 'build/scripts/kernel.js' }
    it { is_expected.to include 'build/scripts/kernel_lib.js' }
    it { is_expected.not_to include 'build/scripts/shell.js' }
  end

  context '#haml_files' do
    subject { app.haml_files }

    it { is_expected.to include 'diff/path/shell.haml' }
  end

end
