require 'spec_helper'
require 'nocker'

module NockerHelpers
  def nounify(atoms,op = :nil_op)
    nouns = atoms.map do | item |
      if item.kind_of?(Array)
        nounify(item) 
      elsif item.kind_of?(Noun)
        item
      else  
        Noun.new(item)
      end
    end 
    Noun.new(nouns,op)
  end 

end 

describe Nocker do
include NockerHelpers 
  before do
    RSpec::Matchers.define :same_as do |expected|
      match do |actual|
          if actual == nil || expected == nil 
            false
          else 
	    expected.equals?(actual)
          end 
      end
      diffable
    end
    @nocker = Nocker.new
  end 

  describe 'reduction 1' do
    it "should leave sub arrays alone" do
      test = nounify([:a,[:a,:b]])
      @nocker.reduce(test).should same_as(test)
    end
    
    it "should returns a cellifyed version of a array of symblos" do
      test = nounify([:a,[:b,:c]])
      @nocker.reduce(nounify([:a,:b,:c])).should same_as(test)
    end
  end

  describe 'reduction 2' do
    it 'should return an atom if it is an atom' do
      @nocker.reduce(Noun.new('a',:'*')).should same_as(Noun.new('a'))
    end
  end

  describe 'reduction 4 and 5' do
    it 'should return 0 if it is a cell' do
      @nocker.reduce(nounify([:a,:b],:'?')).should same_as(Noun.new(0))
    end

    it 'should return 1 if it is a atom' do
      @nocker.reduce(Noun.new(:a,:'?')).should same_as(Noun.new(1))
    end
  end

  describe 'reduction 6' do
    it 'should increment an atom' do
      @nocker.reduce(Noun.new(1,:'+')).should same_as(Noun.new(2))
    end
  end

  describe 'reduction 7 and 8' do
    it 'should return 0 if they are equal' do
      @nocker.reduce(nounify([1,1],:'=')).should same_as(Noun.new(0))
    end

    it 'should return 1 if they are not equal' do
      @nocker.reduce(nounify([1,2],:'=')).should same_as(Noun.new(1))
    end
  end

  describe 'slot reductions (10-14)' do
    it 'should yeild the other item if 0' do
      @nocker.reduce(nounify([1,2],:'/')).should same_as(Noun.new(2))
    end

    it 'should yeild the whole tail set if 1' do
      @nocker.reduce(nounify([1,[2,3]],:'/')).should same_as(nounify([2,3]))
    end
     
    it 'should yeild the BFS indexed item' do
      @nocker.reduce(nounify([2,[[4,5],[6,14,15]]],:'/'))
             .should same_as(nounify([4,5]))
      @nocker.reduce(nounify([3,[[4,5],[6,14,15]]],:'/'))
             .should same_as(nounify([6,[14,15]]))
      @nocker.reduce(nounify([7,[[4,5],[6,14,15]]],:'/'))
             .should same_as(nounify([14,15]))
      end 
    end
    describe 'compisition operator (16)' do
      it 'should compose' do
        @nocker.reduce(nounify([42, [[4, 0, 1], [3, 0, 1]]],:'*'))
               .should same_as(nounify([43,1]))
      end
    end
    describe 'tree addressing operator (18)' do
      it 'should do a tree reduce' do
       test = nounify([[[4,5], [6, [14, 15]]], [0, 7 ]],:'*')
       @nocker.reduce(test).should same_as(nounify([14,15]))
      end
    end
    
    describe 'constant operator (19)' do
      it 'should return b' do
        @nocker.reduce(nounify([42,[1,[153,218]]],:'*'))
               .should same_as(nounify([153,218]))
      end
    end

    describe 'nock operator 20' do
      it 'should compose the things'do
        @nocker.reduce(nounify([77, [2, [1, 42], [1, 1, 153, 218]]],:'*'))
               .should same_as(nounify([153,218]))
      end
    end
    
    describe 'nock operators 21-23' do
      it 'should add a cell test op to reduced noun' do
        @nocker.reduce(nounify([57,[3,0,1]],:'*'))
               .should same_as(Noun.new(1))
      end
      it 'should add a inc op to reduced noun' do
        @nocker.reduce(nounify([[57],[4,0,1]],:'*'))
               .should same_as(Noun.new(58))
      end
      it 'should add a test op reduced noun' do
        @nocker.reduce(nounify([[57,57],[5,0,1]],:'*'))
               .should same_as(Noun.new(0))
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
  
  it "should be able to evaluate positive equlivilance" do
    test = Noun.new(
      [Noun.new(:a),Noun.new(
        [Noun.new(:a),Noun.new(:b)])])
    test.equals?(test).should eq(true) 
  end

  it "should be able to evaluate equlivilance" do
    test = Noun.new(
      [Noun.new(:a),Noun.new(
        [Noun.new(:a),Noun.new(:b)])])
    test1 = Noun.new(
        [Noun.new(1),Noun.new(
          [Noun.new(2),Noun.new(3)])],:slot_op)
    test.equals?(test1).should eq(false) 
  end
end
