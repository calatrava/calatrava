require 'spec_helper'
require 'yaml'

describe Calatrava::Manifest do
  include Aruba::Api

  before(:each) do
    create_dir 'app'
    write_file 'app/manifest.yml', ['included'].to_yaml
  end

  let(:features) {  }
  let(:kernel) { double('kernel',
                        :coffee_files => ['kernel_everywhere'],
                        :features => [{:name => 'included', :coffee => 'k_inc', :haml => 'inc'},
                                      {:name => 'excluded', :coffee => 'k_exc', :haml => 'exc'}]) }
  let(:shell) { double('shell',
                       :coffee_files => ['shell_everywhere'],
                       :haml_files => ['fragment'],
                       :css_files => ['styles'],
                       :features => [{:name => 'included', :coffee => 'shell_inc', :haml => 'inc'},
                                     {:name => 'excluded', :coffee => 'shell_exc', :haml => 'exc'}]) }
  let(:manifest) { Calatrava::Manifest.new(current_dir, 'app', kernel, shell) }

  context 'coffee files' do
    subject { manifest.coffee_files }

    it { should include 'kernel_everywhere' }
    it { should include 'shell_everywhere' }

    it { should include 'k_inc' }
    it { should_not include 'k_exc' }
    it { should include 'shell_inc' }
    it { should_not include 'shell_exc' }
  end

  context 'haml files' do
    subject { manifest.haml_files }

    it { should include 'fragment' }
    it { should include 'inc' }
    it { should_not include 'exc' }
  end

  context '#css_files' do
    subject { manifest.css_files }

    it { should include 'styles' }
  end

end
