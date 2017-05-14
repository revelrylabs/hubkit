require 'spec_helper'

describe Hubkit::ChainableCollection do
  subject(:collection) do
    Hubkit::ChainableCollection.new [
      { donkus: true },
      { donkus: false },
    ]
  end

  it { should respond_to :select }
  it { should respond_to :wrap }
  it 'throws an error if the wrapped collection does not implement a missing method' do
    expect { collection.x_y_z }.to raise_error(NoMethodError)
  end

  it 'delegates down to the wrapped collection' do
    expect { collection.length }.to_not raise_error
  end

  describe '#scope' do
    subject(:test_class) do
      class TestChainable < Hubkit::ChainableCollection;end
      TestChainable
    end

    it { should respond_to :scope }

    it 'define a scope method' do
      test_class.class_eval do
        scope(:even) { select { |number| number.even? } }
      end

      tc = TestChainable.new [1,2,3]
      expect(tc).to respond_to :even

      expect(tc.even).to eq [2]
    end
  end

  describe '#wrap' do
    subject { collection.wrap(['foo', 'bar']) }

    it { should respond_to :wrap }
    it { should respond_to :select }
  end

  describe '#select' do
    context 'with a block' do
      subject do
        Hubkit::ChainableCollection.new([1, 2, 3]).select { |n| n.odd? }
      end

      it { should respond_to :wrap }
      it { should respond_to :select }
      it { should eq [1, 3] }
    end

    context 'without a block' do
      subject do
        Hubkit::ChainableCollection.new([1, 2, 3]).select.select { |n| n.positive? }
      end

      it { should respond_to :wrap }
      it { should respond_to :select }
      it { should eq [1, 2, 3] }
    end
  end

  describe '#not' do
    subject do
      Hubkit::ChainableCollection.new([-1, 0, 1, 2, 3]).not.select { |n| n.positive? }
    end

    it { should respond_to :wrap }
    it { should respond_to :select }
    it { should eq [-1, 0] }
  end
end
