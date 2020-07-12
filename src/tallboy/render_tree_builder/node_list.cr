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
end