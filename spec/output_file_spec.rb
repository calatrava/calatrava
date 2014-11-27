require 'spec_helper'

describe Calatrava::OutputFile do
  let(:file) { Calatrava::OutputFile.new("output directory", source_file, dependencies) }

  context 'coffee file source' do
    let(:source_file) { "coffee file.coffee" }
    let(:dependencies) { [] }

    describe '#output_path' do
      subject { file.output_path }

      it { is_expected.to start_with("output directory/") }
      it { is_expected.to end_with("coffee file.js") }
    end

    describe '#dependencies' do
      subject { file.dependencies }

      it 'has 2 dependencies' do
        expect(subject.size).to eq(2)
      end
      it { is_expected.to include('coffee file.coffee') }
      it { is_expected.to include('output directory') }

      context 'with additional' do
        let(:dependencies) { [:environment] }

        it 'has 3 dependencies' do
          expect(subject.size).to eq(3)
        end
        it { is_expected.to include(:environment) }
      end
    end
  end

end
