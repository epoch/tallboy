module Tallboy
  class Renderer
    @@border_style = {
      "corner_top_left" => "┌",
      "corner_top_right" => "┐",
      "corner_bottom_right" => "┘",
      "corner_bottom_left" => "└",
      "edge_top" => "─",
      "edge_right" => "│",
      "edge_bottom" => "─",
      "edge_left" => "│",
      "tee_top" => "┬",
      "tee_right" => "┤",
      "tee_bottom" => "┴",
      "tee_left" => "├",
      "divider_vertical" => "│",
      "divider_horizontal" => "─",
      "joint_horizontal" => "─",
      "joint_vertical" => "│",
      "cross" => "┼",
      "content" => " "
    }

    def initialize(@render_tree : Array(Array(Node) | NodeList), @border_style = {} of String => String)
      @border_style = @@border_style.merge(@border_style)
    end

    def render_node(node : (Text|MergedNode), line_num = 0)
      node.render(line_num)
    end

    def render_node(node : (Joint|Line), line_num = 0)
      node.render(@border_style)
    end

    def render_list(arr : Array(Node), io)
      arr.each { |node| io << render_node(node) }
    end

    def render_list(list : NodeList, io)
      list.height.times do |line_num|
        list.each do |node|
          io << render_node(node, line_num) 
        end
        io << "\n" unless line_num == list.height - 1
      end
    end

    def render(io = IO::Memory.new)
      @render_tree.each do |row|
        render_list(row, io)
        io << "\n" unless row == @render_tree.last
      end
      io
    end
  end
end