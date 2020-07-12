module Tallboy
  struct ComputedCell
    @width : Int32
    getter :value, :width, :part, :align

    def initialize(@value : String, @width, @part : Part = :tail, @align : Alignment = :left, @span = 1)
    end

    def inspect
      "(#{@part} #{@align.colorize(:yellow)} #{@width.colorize(:green)})"
    end
  end
end