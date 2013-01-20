require 'spec_helper'

describe Calatrava::Kernel do
  include Aruba::Api

  before(:each) do
    create_dir 'kernel'
    create_dir 'kernel/app'
    write_file 'kernel/app/support.coffee', ''
    write_file 'kernel/app/support.js', ''

    create_dir 'kernel/app/mod1'
    write_file 'kernel/app/mod1/first.coffee', ''
    write_file 'kernel/app/mod1/first.js', ''

    create_dir 'kernel/plugins'
    write_file 'kernel/plugins/plugin.one.coffee', ''
    write_file 'kernel/plugins/plugin.one.js', ''
    write_file 'kernel/plugins/two.coffee', ''
    write_file 'kernel/plugins/two.js', ''
  end

  let(:kernel) { Calatrava::Kernel.new(current_dir) }

  context '#features' do
    subject { kernel.features }

    it { should have(1).features }

    context 'a single feature' do
      subject { kernel.features[0] }

      it { should include :name => 'mod1' }
      it { should include :coffee => ['kernel/app/mod1/first.coffee'] }
      it { should include :js => ['kernel/app/mod1/first.js'] }
    end
  end

  context '#coffee_files' do
    subject { kernel.coffee_files }

    it { should have(3).files }
    it { should include 'kernel/app/support.coffee' }
    it { should include 'kernel/plugins/plugin.one.coffee' }
    it { should include 'kernel/plugins/two.coffee' }
  end

  context '#js_files' do
    subject { kernel.js_files }

    it { should have(3).files }
    it { should include 'kernel/app/support.js' }
    it { should include 'kernel/plugins/plugin.one.js' }
    it { should include 'kernel/plugins/two.js' }
  end

  context '#coffee_path' do
    subject { kernel.coffee_path }

    it { should include 'app:' }
    it { should include 'app/mod1' }
    it { should include 'app/plugins' }
  end

end
