module Tallboy
  struct Line
    def initialize(cell : ComputedCell)
      @width = cell.width.as(Int32)
      @type = "edge_top"
    end

    def height
      1
    end

    def render(lookup = {} of String => String)
      lookup[@type] * @width
    end
    
    def inspect
      "(line #{@width})"
    end  
  end
end