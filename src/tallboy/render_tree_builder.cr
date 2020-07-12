require "./render_tree_builder/node"
require "./render_tree_builder/node_list"

module Tallboy
  class RenderTreeBuilder
    def initialize(@table : ComputedTable)
    end

    def merge_nodes(node : Node)
      node
    end

    def merge_nodes(nodes : Array(Node|Text))
      if nodes.size == 1
        nodes.first
      else
        MergedNode.new(nodes)
      end
    end

    def build_nodes(arr)
      [
        arr.flat_map do |cell|
          if cell.part.tail?
            [Text.new(cell)]
          else
            [Text.new(cell), Joint.new(type: "joint_horizontal")]
          end
        end,
        Joint.new(type: "divider_vertical")
      ]    
    end

    def build_row(row)
      NodeList.new(
        row.slice_when do |cell|
          cell.part.tail?
        end.to_a.flat_map do |arr| 
          build_nodes(arr)
        end.tap(&.pop).map do |arr|
          merge_nodes(arr)
        end.tap do |nodes|
          nodes.unshift Joint.new(type: "edge_left")
          nodes.push Joint.new(type: "edge_right")
        end #.map(&.as(Node))
      )
    end

    def border_between(prev_row, next_row, cross, left, right)
      prev_row.cells.zip(next_row.cells).flat_map do |(p, n)|
        case {p.part, n.part}
        when {Part::Body, Part::Body}
          [Line.new(p), Joint.new(type: "divider_horizontal")]
        when {Part::Body, Part::Tail}
          [Line.new(p), Joint.new(type: "tee_top")]
        when {Part::Tail, Part::Body}
          [Line.new(p), Joint.new(type: "tee_bottom")]
        else
          [Line.new(p), Joint.new(type: cross)]
        end
      end.tap do |nodes|
        nodes.pop
        nodes.unshift Joint.new(type: left)
        nodes.push Joint.new(type: right)
      end.map(&.as(Node))
    end

    def border_top(row)
      border_between(row, row, "tee_top", "corner_top_left", "corner_top_right")
    end

    def border_bottom(row)
      border_between(row, row, "tee_bottom", "corner_bottom_left", "corner_bottom_right")
    end

    def build_border(prev_row, next_row)
      case { prev_row, next_row }
      when { Nil, ComputedRow }
        border_top(next_row)
      when { ComputedRow, Nil }
        border_bottom(prev_row)
      when { ComputedRow, ComputedRow }
        border_between(prev_row, next_row, "cross", "tee_left", "tee_right")
      else
        raise "not sure"
      end
    end

    def build
      render_list = [] of Array(Node) | NodeList
      @table.each_row do |row, prev_row, next_row, idx|
        if row.border.top? || @table.border.top? && row == @table.first
          render_list << build_border(prev_row, row) 
        end
        render_list << build_row(row)
        if row.border.bottom? || @table.border.bottom? && row == @table.last
          render_list << build_border(row, next_row) 
        end
      end
      render_list
    end
  end
end