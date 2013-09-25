require 'spec_helper'
require 'nocker'
describe Nocker do
  before do
      @nocker = Nocker.new
    end 
  describe 'reduction 1' do
    test = Noun.new(
      [Noun.new(:a),Noun.new(
        [Noun.new(:a),Noun.new(:b)])])
    it "should leave sub arrays alone" do
      @nocker.reduce(test).cell.should eql(test)
    end
    
    test2 = Noun.new(Noun.new([Noun.new(:a),Noun.new(:b),Noun.new(:c)]))
    it "should returns a cellifyed version of a array of symblos" do
      @nocker.reduce(test2).cell.should eql(test)
    end
  end

  describe 'reduction 2' do
    it 'should return an atom if it is an atom' do
      @nocker.reduce(Noun.new('a',:nock_op)).type.should eq(:atom)
    end
  end

  describe 'reduction 4 and 5' do
    it 'should return 0 if it is a cell' do
      test4 = Noun.new([Noun.new(:a),Noun.new(:b)],:test_op)
      @nocker.reduce(test4).type.should eq(:atom)
      test4b= Noun.new([Noun.new(:a), Noun.new(:b)],:test_op)
      @nocker.reduce(test4b).atom.should eql(0)
    end

    it 'should return 1 if it is a atom' do
      @nocker.reduce(Noun.new(:a,:test_op)).type.should eq(:atom)
      @nocker.reduce(Noun.new(:a,:test_op)).atom.should eql(1)
    end
  end

  describe 'reduction 6' do
    it 'should increment an atom' do
      @nocker.reduce(Noun.new(1,:inc_op)).atom.should eql(2)
    end
  end

  describe 'reduction 7 and 8' do
    it 'should return 0 if they are equal' do
      test7 = Noun.new([Noun.new(1),Noun.new(1)],:eq_op)
      @nocker.reduce(test7).atom.should eql(0)
    end

    it 'should return 1 if they are not equal' do
      test7 = Noun.new([Noun.new(1),Noun.new(2)],:eq_op)
      @nocker.reduce(test7).atom.should eql(1)
    end
  end

  describe 'slot reductions (10-14)' do
    it 'should yeild the other item if 0' do
      test10 = Noun.new([Noun.new(1),Noun.new(2)],:slot_op)
      @nocker.reduce(test10).atom.should eql(2)
    end

    it 'should yeild the whole tail set if 1' do
      test11 = Noun.new(
        [Noun.new(1),Noun.new(
          [Noun.new(2),Noun.new(3)])],:slot_op)
      s11 = Noun.new([Noun.new(2),Noun.new(3)])
      @nocker.reduce(test11).cell.should eql(s11)
    end

    it 'should yeild the BFS indexed item' do
      @nocker.reduce(Noun.new([2,[[4,5],[6,14,15]]],:slot_op)).cell.should eql([4,5])
      @nocker.reduce(Noun.new([3,[[4,5],[6,14,15]]],:slot_op)).cell.should eql([6,14,15])
      @nocker.reduce(Noun.new([7,[[4,5],[6,14,15]]],:slot_op)).cell.should eql([14,15])
    end 
  end
end

describe Noun do
  it "should create a atom when given an atom" do
    Noun.new("x").atom.should eq("x") 
    Noun.new("x").type.should eq(:atom) 
  end
  it "should create a cell when passed an array" do
    Noun.new([:x,:y]).cell.should eq([:x,:y])
    Noun.new([:x,:y]).type.should eq(:cell)
    Noun.new([:x,:y]).op.should eq(:nil_op)
  end
end
