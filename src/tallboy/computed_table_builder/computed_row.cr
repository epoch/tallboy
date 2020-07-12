module Tallboy
  struct ComputedRow
    include Enumerable(ComputedCell)
    include Iterable(ComputedCell)
    getter :cells, :border
    @cells : Array(ComputedCell)

    def initialize(@cells, @border : Border = :none)
    end

    def each(&block)
      @cells.each {|c| yield c }
    end

    def each
      @cells
    end
  end
end