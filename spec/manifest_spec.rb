require 'spec_helper'
require 'yaml'

describe Calatrava::Manifest do
  include Aruba::Api

  before(:each) do
    create_dir 'app'
    write_file 'app/manifest.yml', ['included'].to_yaml
  end

  let(:features) {}
  let(:kernel) { double('kernel',
                        :coffee_files => ['kernel.coffee'],
                        :js_files => ['kernel.js'],
                        :features => [{:name => 'included', :coffee => 'included_kernel.coffee', :js => 'included_kernel.js'},
                                      {:name => 'excluded', :coffee => 'excluded_kernel.coffee', :js => 'excluded_kernel.js'}]) }
  let(:shell) { double('shell',
                       :coffee_files => ['shell.coffee'],
                       :haml_files => ['fragment'],
                       :js_files => ['shell.js'],
                       :css_files => ['styles'],
                       :features => [{:name => 'included', :coffee => 'included_shell.coffee', :js => 'included_shell.js', :haml => 'included.haml'},
                                     {:name => 'excluded', :coffee => 'exluded_shell.coffee', :js => 'excluded_shell.js', :haml => 'excluded.haml'}]) }
  let(:manifest) { Calatrava::Manifest.new(current_dir, 'app', kernel, shell) }

  context 'coffee files' do
    subject { manifest.coffee_files }

    it { should include 'kernel.coffee' }
    it { should include 'shell.coffee' }

    it { should include 'included_kernel.coffee' }
    it { should_not include 'excluded_kernel.coffee' }
    it { should include 'included_shell.coffee' }
    it { should_not include 'exluded_shell.coffee' }
  end

  context 'js files' do
    subject { manifest.js_files }

    it { should include 'kernel.js' }
    it { should include 'shell.js' }

    it { should include 'included_kernel.js' }
    it { should_not include 'excluded_kernel.js' }
    it { should include 'included_shell.js' }
    it { should_not include 'exluded_shell.js' }
  end

  context 'haml files' do
    subject { manifest.haml_files }

    it { should include 'fragment' }
    it { should include 'included.haml' }
    it { should_not include 'excluded.haml' }
  end

  context '#css_files' do
    subject { manifest.css_files }

    it { should include 'styles' }
  end

  context '#kernel_bootstrap' do
    subject { manifest.kernel_bootstrap }

    it { should include 'included_kernel.coffee' }
    it { should include 'kernel.coffee' }

    it { should_not include 'excluded_kernel.coffee' }
    it { should_not include 'shell.coffee' }
    it { should_not include 'included_shell.coffee' }
  end

end
