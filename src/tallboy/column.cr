module Tallboy
  class Column
    @cells : Array(Cell)
    include Enumerable(Cell)
    getter :cells

    def initialize(@cells : Array(Cell))
    end

    def each
      cells.each do |cell|
        yield(cell)
      end
    end

    def align=(align : Align)
      align(align)
    end

    def align(align : Align)
      cells.each do |cell|
        cell.align = align
      end
    end

    def wrap_text(wrap_by : Symbol, max_line_size : Int32)
      @cells.each { |cell| cell.wrap_text(wrap_by, max_line_size) }
    end
  end
end
