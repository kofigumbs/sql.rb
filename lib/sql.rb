def sql(&block)
  statement = Statement.new
  statement.instance_exec(&block)

  # private instance variables avoid polluting the DSL
  selections = statement.instance_variable_get(:@selections)
  from_table = statement.instance_variable_get(:@from_table)
  conditions = statement.instance_variable_get(:@conditions)

  s = "SELECT #{selections.map { |expr| escape(expr) }.join(", ")}"
  s += " FROM #{escape(from_table)}" if from_table
  s += " WHERE #{conditions.first}" unless conditions.empty?
  s += ";"
end

def escape(expr)
  case expr
  when Literal then expr.value
  when Integer then expr.to_s
  when String then "'#{expr}'"
  else raise "CannotEscape: #{expr.inspect}"
  end
end

class Literal
  attr_reader :value

  def initialize(conditions, value)
    @conditions = conditions
    @value = value
  end

  def method_missing(symbol, *args)
    name = symbol.to_s
    if args.empty?
      # ruby dot access, which maps to table column access
      Literal.new(@conditions, "#{value}.#{name}")
    elsif name.end_with?("=")
      # ruby assignment, which maps to SQL equality condition
      @conditions.push("#{name.chop} = #{escape(args.first)}")
    else
      # ruby method call
      super
    end
  end

  def !=(other)
    @conditions.push("#{value} != #{escape(other)}")
  end
end

class Statement
  def initialize
    @selections = []
    @from_table = nil
    @conditions = []
  end

  def method_missing(symbol, *args)
    return super unless args.empty?

    Literal.new(@conditions, symbol.to_s)
  end

  def SELECT(*columns)
    @selections = columns
  end

  def FROM(table)
    @from_table = table
  end

  def WHERE(*)
  end
end
