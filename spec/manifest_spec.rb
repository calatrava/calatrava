require 'spec_helper'
require 'yaml'

describe Calatrava::Manifest do
  include Aruba::Api

  before(:each) do
    create_dir 'app'
    write_file 'app/manifest.yml', {'features' => ['included'], 'kernel_libs' => ['kernel_lib.js']}.to_yaml
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

    it { is_expected.to include 'kernel_everywhere' }
    it { is_expected.to include 'shell_everywhere' }

    it { is_expected.to include 'k_inc' }
    it { is_expected.not_to include 'k_exc' }
    it { is_expected.to include 'shell_inc' }
    it { is_expected.not_to include 'shell_exc' }
  end

  context 'haml files' do
    subject { manifest.haml_files }

    it { is_expected.to include 'fragment' }
    it { is_expected.to include 'inc' }
    it { is_expected.not_to include 'exc' }
  end

  context '#css_files' do
    subject { manifest.css_files }

    it { is_expected.to include 'styles' }
  end

  context '#kernel_bootstrap' do
    subject { manifest.kernel_bootstrap }

    it { is_expected.to include 'k_inc' }
    it { is_expected.to include 'kernel_everywhere' }

    it { is_expected.not_to include 'k_exc' }
    it { is_expected.not_to include 'shell_everywhere' }
    it { is_expected.not_to include 'shell_inc' }
  end

  context '#kernel_libraries' do
    context "#when present" do
      subject { manifest.kernel_libraries }

      it { is_expected.to include 'kernel_lib.js'}
    end

    context "#when not present" do
      before do
        write_file 'app/manifest.yml', {'features' => ['included'], 'kernel_libs' => nil}.to_yaml
      end

      subject { manifest.kernel_libraries }

      it { is_expected.to be_empty}
    end
  end

end
