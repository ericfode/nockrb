require 'logger' 
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
  def inspect()
    case @type
    when :cell
      op = ""
      if @op != :nil_op
        op = "#{@op}" 
      end
      items = @cell.map do |item|
        item.inspect
      end
      return op + '[' + items.join(' ') + ']' 
      when :atom
        return @atom
    end
  end
  def initialize(cell, op=:nil_op)
    @op =op 
    if cell.kind_of?(Array) && cell.length == 1
      cell = cell[0]
    end
    if cell.kind_of?(Array)
      @cell = cell
      @type = :cell
    elsif cell.kind_of?(Noun)
      @atom = cell.atom
      @cell = cell.cell
      @type = cell.type
    else
      @atom = cell
      @type = :atom
    end
  end
end

class Nocker
  def initialize
    @log = Logger.new(STDOUT)
  end

  def reduce(noun)
    @log.info("#{noun.inspect}") 
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
          return noun
      end
      # reuction 1

    when :'*'
      case noun.type
      when :atom
        return noun
      when :cell
        case noun.cell[1].cell[0].type
        when :cell
          innerleft = reduce(noun.cell[1].cell[0])
          innerright = reduce(noun.cell[1].cell[1])
          return reduce(Noun.new([
            reduce(Noun.new(
              [noun.cell[0],innerleft],:'*')),
            reduce(Noun.new(
              [noun.cell[0],innerright],:'*'))]))
        when :atom
          case noun.cell[1].cell[0].atom
          when 0
            #reduction 18
            return reduce(Noun.new([ noun.cell[1].cell[1],noun.cell[0]],:'/'))
          when 1
            #reduction 19
            return reduce(noun.cell[1]).cell[1]

          when 2
            inner = reduce(noun.cell[1]) 
            a = noun.cell[0]
            b = inner.cell[1].cell[0]
            c = inner.cell[1].cell[1]
            return reduce(Noun.new([
              reduce(Noun.new([a,b],:'*')),
              reduce(Noun.new([a,c],:'*'),)],:'*'))
          when 3
            return reduce(Noun.new([
                    reduce(Noun.new([
                        noun.cell[0],
                        reduce(noun.cell[1]).cell[1]],:'*'))],
                        :'?'))
          when 4
            return reduce(Noun.new([
                    reduce(Noun.new([
                        noun.cell[0],
                        reduce(noun.cell[1]).cell[1]],:'*'))],
                        :'+'))
          when 5
            return reduce(Noun.new([
                    reduce(Noun.new([
                        noun.cell[0],
                        reduce(noun.cell[1]).cell[1]],:'*'))],
                        :'='))
          end
        end
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
        raise 'you gave me an atom for + op'
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
      when :atom
          raise ' you gave me an atom for = op'
      end 
    when :'/'
      case noun.type
      when :cell
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
    
    raise"missed the boat"
  end

end
