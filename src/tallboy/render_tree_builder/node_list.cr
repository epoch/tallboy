module Tallboy
  class NodeList
    include Enumerable(Node)
    @nodes : Array(Node)

    def initialize(nodes : Array)
      @nodes = nodes.map(&.as(Node))
    end

    def <<(node)
      @nodes << node
    end

    def height
      @nodes.map { |node| node.height }.max || 1
    end

    def each
      @nodes.each {|n| yield n }
    end
  end

  class MinWidthCalculator
    def initialize(@table : TableBuilder)
    end

    def calculate
      @table.columns.map_with_index do |_, idx|
        column(idx).max? ? column(idx).max + PADDING_LEFT + PADDING_RIGHT : 0
      end
    end

    private def column(idx)
      @table.map do |row| 
        case row
        when Row
          row[idx].size 
        else
          (row.value.to_s.size / @table.columns.size).ceil.to_i
        end
      end
    end    
  end
end