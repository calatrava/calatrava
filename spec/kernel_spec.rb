require 'spec_helper'

describe Calatrava::Kernel do
  include Aruba::Api

  before(:each) do
    create_dir 'kernel'
    create_dir 'kernel/app'
    write_file 'kernel/app/support.coffee', ''

    create_dir 'kernel/app/mod1'
    write_file 'kernel/app/mod1/first.coffee', ''

    create_dir 'kernel/plugins'
    write_file 'kernel/plugins/plugin.one.coffee', ''
    write_file 'kernel/plugins/two.coffee', ''
  end

  let(:kernel) { Calatrava::Kernel.new(current_dir) }

  context '#features' do
    subject { kernel.features }

    it 'has 1 feature' do
      expect(subject.size).to eq(1)
    end

    context 'a single feature' do
      subject { kernel.features[0] }

      it { is_expected.to include :name => 'mod1' }
      it { is_expected.to include :coffee => ['kernel/app/mod1/first.coffee'] }
    end
  end

  context '#coffee_files' do
    subject { kernel.coffee_files }

    it 'has 3 files' do
      expect(subject.size).to eq(3)
    end
    it { is_expected.to include 'kernel/app/support.coffee' }
    it { is_expected.to include 'kernel/plugins/plugin.one.coffee' }
    it { is_expected.to include 'kernel/plugins/two.coffee' }
  end

  context '#coffee_path' do
    subject { kernel.coffee_path }

    it { is_expected.to include 'app:' }
    it { is_expected.to include 'app/mod1' }
    it { is_expected.to include 'app/plugins' }
  end

end
