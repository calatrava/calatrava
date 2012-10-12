require 'spec_helper'

describe Calatrava::MobileWebApp do
  include Aruba::Api

  before(:each) do
    create_dir 'web'
    create_dir 'web/app/source'
    write_file 'web/app/source/support.coffee', ''

    proj = double('current project', :config => double('cfg', :path => 'env.coffee'))
    Calatrava::Project.stub(:current).and_return(proj)
  end

  let(:manifest) { double('web mf',
                          :coffee_files => ['path/to/kernel.coffee', 'diff/path/shell.coffee'],
                          :haml_files => ['diff/path/shell.haml']) }

  let(:mobile_web) { Calatrava::MobileWebApp.new(current_dir, manifest) }

  it 'should define the correct output directories' do
    mobile_web.build_dir.should match %r{web/public$}
    mobile_web.scripts_build_dir.should match %r{web/public/scripts$}
  end

  context '#coffee_files' do
    subject { mobile_web.coffee_files }

    it { should include 'path/to/kernel.coffee' }
    it { should include 'diff/path/shell.coffee' }
    it { should include 'web/app/source/support.coffee' }
    it { should include 'env.coffee' }
  end

  context '#scripts' do
    subject { mobile_web.scripts }

    it { should include 'scripts/kernel.js' }
    it { should include 'scripts/shell.js' }
    it { should include 'scripts/support.js' }
  end

  context '#haml_files' do
    subject { mobile_web.haml_files }

    it { should include 'diff/path/shell.haml' }
  end

end
