module Tallboy
  class Row
    @cells : Array(Cell)
    include Enumerable(Cell)

    getter :cells
    property :border_bottom

    def initialize(
      data : Array(CellValue),
      layout = [] of Int32,
      @border_bottom = false,
    )
      @layout = Layout.new(data.size, layout)
      @cells = build_cells(data)
    end

    def layout
      @layout.spans
    end

    def border_bottom?
      @border_bottom
    end

    def height
      cells.map { |cell| cell.lines.size }.max || 1
    end

    def each
      cells.each do |cell|
        yield(cell)
      end
    end

    def layout=(arr)
      @layout = Layout.new(cells.size, arr)
      @layout.each_with_index {|span, i| @cells[i].span = span }
    end

    def build_cells(elems)
      elems.zip(@layout.spans).map do |elem, span|
        Cell.new(data: elem, span: span)
      end      
    end

    def cell(num)
      @cells[num]
    end

  end
end