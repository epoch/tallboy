module Tallboy
  struct Row
    include Enumerable(Cell)
    getter :cells, :border

    def initialize(@cells = [] of Cell, @border : Border = :none)
    end

    def cell(value, span : Int32 = 1, align : AlignValue = :auto)
      (span - 1).times do
        @cells << Cell.new(value.to_s, span: span, part: :body, align: align)
      end
      @cells << Cell.new(value.to_s, span: span, part: :tail, align: align)
    end

    def size
      @cells.size
    end

    def [](idx)
      @cells[idx]
    end

    def each
      @cells.each {|c| yield c }
    end
  end
end