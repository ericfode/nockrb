
class Noun 
  attr_accessor :cell 
  attr_accessor :op
  attr_accessor :atom
  attr_accessor :type
  
  def equals?(other)
    if other == nil
      return false
    end
    if other.type == @type
      case @type
      when :cell  
        res=[]
        @cell.each_index do | i |
          res.push(@cell[i].equals?(other.cell[i]))
        end
        res.reduce(:&)
      when :atom
        other.atom == @atom
      end
    end
  end
  def initialize(cell, op=:nil_op)
    @op =op 
    if cell.kind_of?(Array)
      @cell = cell
      @type = :cell
    else
      @atom = cell
      @type = :atom
    end
    
  end

end

class Nocker
  def reduce(noun)
    case noun.op
    # reduction 0
    when :nil_op
      case noun.type
      when :cell
        if noun.cell.length > 2
          slice = Noun.new(noun.cell[0,noun.cell.length-2] << Noun.new(noun.cell[-2..-1]))
          return reduce(slice)
        end
        return noun
      when :atom
        if noun.atom.kind_of? Noun
          return reduce(noun.atom)
        end
          return noun
      end
      # reuction 1

    when :'*'
      case noun.type
      when :atom
        return noun
      when :cell
        puts noun.inspect
        return Noun.new(noun)
      end
    
    when :'?'
      case noun.type
      # reduction 4
      when :atom
        return Noun.new(1)
      #reduction 5
      when :cell
        return Noun.new(0)
      end
    when :'+'
      case noun.type
      when :atom
        return Noun.new(noun.atom + 1)
      when :cell
        raise "idiot you gave me a cell where i can only take a atom inc_op"
      end
    #reduction 7 and 8 
    when :'='
      case noun.type
      when :cell

        if noun.cell[0].atom == noun.cell[1].atom
          return Noun.new(0)
        else
          return Noun.new(1)
        end
      end 
    when :'/'
      case noun.type
      when :cell
        puts noun.inspect
        slot = noun.cell[0].atom
        if slot == 1
          return reduce(noun.cell[1])
        else
          
          inner = reduce(noun.cell[1])
          head = inner.cell[0] 
          tail = inner.cell[1]
          if slot % 2 == 0
            slot_new= Noun.new(slot/2)
            return reduce(Noun.new([slot_new].push(reduce(head)), :/))
          else
            slot_new = Noun.new((slot-1)/2)
            return reduce(Noun.new([slot_new].push(reduce(tail)), :/))
          end
        end
      end
    end
    puts "missed the boat"
    puts noun.inspect
  end

end
