require 'spec_helper'

describe Calatrava::MobileWebApp do
  include Aruba::Api

  before(:each) do
    create_dir 'web'
    create_dir 'web/app/source'
    write_file 'web/app/source/support.coffee', ''

    proj = double('current project', :config => double('cfg', :path => 'env.coffee'))
    allow(Calatrava::Project).to receive(:current).and_return(proj)
  end

  let(:manifest) { double('web mf',
                          :coffee_files => ['path/to/kernel.coffee', 'diff/path/shell.coffee'],
                          :haml_files => ['diff/path/shell.haml']) }

  let(:mobile_web) { Calatrava::MobileWebApp.new(current_dir, manifest) }

  it 'should define the correct output directories' do
    expect(mobile_web.build_dir).to match %r{web/public$}
    expect(mobile_web.scripts_build_dir).to match %r{web/public/scripts$}
  end

  context '#coffee_files' do
    subject { mobile_web.coffee_files.collect { |cf| cf.source_file.to_s } }

    it { is_expected.to include 'path/to/kernel.coffee' }
    it { is_expected.to include 'diff/path/shell.coffee' }
    it { is_expected.to include 'web/app/source/support.coffee' }
    it { is_expected.to include 'env.coffee' }
  end

  context '#scripts' do
    subject { mobile_web.scripts }

    it { is_expected.to include 'scripts/kernel.js' }
    it { is_expected.to include 'scripts/shell.js' }
    it { is_expected.to include 'scripts/support.js' }
  end

  context '#haml_files' do
    subject { mobile_web.haml_files }

    it { is_expected.to include 'diff/path/shell.haml' }
  end

end
