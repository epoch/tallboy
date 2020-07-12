module Tallboy
  struct MergedNode
    def initialize(@nodes : Array(Joint | Text))
    end

    def height
      @nodes.map(&.height).max
    end

    def render(line_num = 0)
      node = @nodes.first.as(Text)
      node.with_align(
        node.with_padding(node.value(line_num)),
        node.align,
        @nodes.map(&.width).sum
      )
    end

    def inspect
      "(merged node #{@nodes.map(&.width)})"
    end
  end
end