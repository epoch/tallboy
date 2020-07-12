module Tallboy
  enum Part
    Body
    Tail

    def tail?
      self == Part::Tail
    end

    def body?
      self == Part::Body
    end
  end

  struct Cell
    getter :span, :part, :align, :value

    def initialize(@value : String, @align : AlignValue = :auto, @part : Part = :tail, @span = 1)
    end

    def size
      @value.size
    end
  end
end