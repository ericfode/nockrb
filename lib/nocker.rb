
class Noun 
  attr_accessor :cell 
  attr_accessor :op
  attr_accessor :atom
  attr_accessor :type

  def initialize(cell, op=:nil_op)
    @op =op 
    if cell.kind_of?(Array)
      if cell.length == 1
        @atom = cell[0]
        @type = :atom
      else
        @cell = cell
        @type = :cell
      end
    else
      @atom = cell
      @type = :atom
    end
  end

end

class Nocker
  symbols = {}
  def reduce(noun)
    case noun.op
      # reduction 0
    when :nil_op
      case noun.type
      when :cell
        if noun.cell.length > 2
        return reduce(
          Noun.new(
            noun.cell.slice(0,noun.cell.length-2).push(noun.cell.slice(-2,2))))
        end
        return noun
      when :atom
        return noun 
      end
      # reuction 1

    when :nock_op
      case noun.type
      when :atom
        return noun
      when :cell
        puts noun.inspect
        return Noun.new(noun)
      end
    
    when :test_op
      case noun.type
      # reduction 2
      when :atom
        return Noun.new(1)
      #reduction 3
      when :cell
        return Noun.new(0)
      end
    when :inc_op
      case noun.type
      when :atom
        return Noun.new(noun.atom + 1)
      when :cell
        raise "idiot you gave me a cell where i can only take a atom inc_op"
      end
    #reduction 7 and 8 
    when :eq_op
      case noun.type
      when :cell

        if noun.cell[0].atom == noun.cell[1].atom
          return Noun.new(0)
        else
          return Noun.new(1)
        end
      end 
    when :slot_op
      case noun.type
      when :cell
        puts noun.inspect
        slot = noun.cell[0].atom
        if slot == 1
          return noun.cell[1]
        else
          inner = noun.cell[1]
          head = inner[0] 
          tail = inner[1]
          if slot % 2 == 0
            slot_new= Noun.new(slot/2)
            return reduce(Noun.new([slot_new, head], :slot_op))
          else
            slot_new = Noun.new((slot-1)/2)
            return reduce(Noun.new([slot_new, tail], :slot_op))
          end
        end
      end
    end
    puts "missed the boat"
    puts noun.inspect
  end

end
