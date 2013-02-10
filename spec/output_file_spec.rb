require 'spec_helper'

describe Calatrava::OutputFile do
  let(:file) { Calatrava::OutputFile.new("output directory", source_file, dependencies) }

  context 'coffee file source' do
    let(:source_file) { "coffee file.coffee" }
    let(:dependencies) { [] }

    describe '#output_path' do
      subject { file.output_path }

      it { should start_with("output directory/") }
      it { should end_with("coffee file.js") }
    end

    describe '#dependencies' do
      subject { file.dependencies }

      it { should have(2).dependencies }
      it { should include('coffee file.coffee') }
      it { should include('output directory') }

      context 'with additional' do
        let(:dependencies) { [:environment] }

        it { should have(3).dependencies }
        it { should include(:environment) }
      end
    end
  end

end
