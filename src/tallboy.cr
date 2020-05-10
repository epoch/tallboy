module Tallboy
  VERSION = "0.9.0"

  PADDING_LEFT = 1
  PADDING_RIGHT = 1

  alias ValueType = String | Int32 | Float32 | Float64
  alias WidthValue = Int32 | WidthOption
  alias AlignValue = Alignment | AlignOption
  alias Node = Text | Line | Joint | MergedNode

  enum Alignment
    Left
    Right
    Center
  end

  enum AlignOption
    Auto
  end

  enum WidthOption
    Auto
  end

  enum Part
    Body
    Tail

    def tail?
      self == Part::Tail
    end

    def body?
      self == Part::Body
    end
  end

  enum Border
    None
    Top
    Bottom
    TopBottom

    def top?
      self == Border::Top || self == Border::TopBottom
    end

    def bottom?
      self == Border::Bottom || self == Border::TopBottom
    end
  end

  enum BorderStyle
    Ascii
    Unicode
    Markdown
  end

  struct Cell
    @value : ValueType
    getter :span, :part, :align

    def initialize(@value, @align : AlignValue = AlignOption::Auto, @part : Part = :tail, @span = 1)
    end
    
    def value
      @value.to_s
    end

    def size
      @value.to_s.size
    end
  end

  struct AutoSpanRow
    getter :align, :border
    
    def initialize(@value : ValueType, @align : AlignValue, @border : Border = :none)
    end

    def value
      @value.to_s
    end

    def size() 1; end
  end

  struct Row
    include Enumerable(Cell)
    getter :cells, :border

    def initialize(@cells = [] of Cell, @border : Border = :none)
    end

    def cell(value, span : Int32 = 1, align : AlignValue = AlignOption::Auto)
      (span - 1).times do
        @cells << Cell.new(value, span: span, part: :body, align: align)
      end
      @cells << Cell.new(value, span: span, part: :tail, align: align)
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

  class TableBuilder
    include Enumerable(Row|AutoSpanRow)
    getter :border, :columns

    def self.new(border : Border = :top_bottom, &block)
      instance = new(border)
      with instance yield
      instance
    end

    def initialize(@border : Border = :none)
      @rows = [] of Row | AutoSpanRow
      @columns = ColumnDefinitions.new
    end

    def columns(header = false, &block)
      with @columns yield
      header() if header
      self
    end

    def header
      header(@columns.map(&.name))
    end

    def row(arr : Array(ValueType), border : Border = :none)
      @rows << Row.new(arr.map {|elem| Cell.new(elem) }, border)
    end

    def row(value : ValueType, align : AlignValue = AlignOption::Auto, border : Border = :none)
      @rows << AutoSpanRow.new(value, align, border)
    end

    def row(border : Border = :none, &block)
      row = Row.new(border: border)
      with row yield
      @rows << row
    end

    def rows(rows : Array(Array(ValueType)))
      rows.each do |row|
        row(row)
      end
    end

    def header(arr : Array(ValueType))
      row(arr, Border::Bottom)
    end

    def header(value : ValueType, align : AlignValue = AlignOption::Auto)
      row(value, align: align, border: :bottom)
    end

    def header(&block)
      row = Row.new(border: :bottom)
      with row yield
      @rows << row
    end

    def footer(arr : Array(ValueType))
      row(arr, Border::Top)
    end

    def footer(value : ValueType, align : AlignValue = AlignOption::Auto)
      row(value, align, :top)
    end

    def footer(&block)
      row = Row.new(border: :top)
      with row yield
      @rows << row
    end

    def each
      @rows.each {|r| yield r }
    end

    def build
      if @columns.empty?
        @columns = ColumnDefinitions.new(@rows.map(&.size).max)
      end

      raise "invalid row cell size" unless @rows.select(&.is_a?(Row)).all? {|r| r.size == @columns.size}

      RenderTreeBuilder.new(
        ComputedTableBuilder.new(
          self, 
          MinWidthCalculator.new(self).calculate
        ).build
      ).build
    end
    
    def render(border_style : BorderStyle, io = IO::Memory.new)
      case border_style
      when BorderStyle::Ascii
        AsciiRenderer.new(self.build).render(io)
      when BorderStyle::Markdown
        MarkdownRenderer.new(self.build).render(io)
      else
        Renderer.new(self.build).render(io)
      end
    end

    def to_s(io)
      Renderer.new(self.build).render(io)
    end
  end

  record ColumnDefinition, 
    name : String = "", 
    width : WidthValue = WidthOption::Auto, 
    align : AlignValue = AlignOption::Auto


  class ColumnDefinitions
    include Enumerable(ColumnDefinition)
    getter :columns

    def self.new(column_count : Int32)
      new(Array.new(column_count, ColumnDefinition.new))
    end

    def initialize(@columns = [] of ColumnDefinition)
    end

    def add(name, width : WidthValue = WidthOption::Auto, align : AlignValue = AlignOption::Auto)
      @columns << ColumnDefinition.new(name, width, align)
    end

    def each
      @columns.each {|c| yield c }
    end
  end

  struct ComputedCell
    @value : ValueType
    @width : Int32
    getter :value, :width, :part, :align

    def initialize(@value, @width, @part : Part = :tail, @align : Alignment = :left, @span = 1)
    end

    def inspect
      "(#{@part} #{@align.colorize(:yellow)} #{@width.colorize(:green)})"
    end
  end

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

  class ComputedTable
    include Enumerable(ComputedRow)
    getter :border

    def initialize(@rows : Array(ComputedRow), @border : Border)
    end

    def each_row
      @rows.each_with_index do |row, idx|
        yield row, prev_row(idx), next_row(idx), idx
      end
    end

    def each(&block)
      @rows.each {|r| yield r }
    end

    def first
      @rows.first
    end

    def last
      @rows.last
    end  

    private def prev_row(idx)
      return nil if idx == 0
      @rows[idx - 1]
    end

    private def next_row(idx)
      @rows[idx + 1]?
    end  
  end

  class ComputedTableBuilder
    getter :min_widths

    def initialize(@table : TableBuilder, @min_widths : Array(Int32))
    end

    def build
      ComputedTable.new(build_rows, @table.border)
    end

    def build_rows
      @table.map do |row|
        build_row(row)
      end
    end

    def build_row(row)
      ComputedRow.new(cells_for(row), border: row.border)
    end

    def cells_for(row : Row)
      row.zip(@table.columns.columns, min_widths).map do |(cell, column, min_width)|
        ComputedCell.new(
          cell.value,
          calc_width(column.width, min_width),
          cell.part,
          calc_align(cell.align, column.align)
        )
      end
    end

    def cells_for(row : AutoSpanRow)
      Array(String).new(min_widths.size, row.value)
        .zip(@table.columns.columns, min_widths)
        .map_with_index do |(cell, column, min_width), idx|
          if idx == @table.columns.columns.size - 1
            ComputedCell.new(
              cell, 
              calc_width(column.width, min_width),
              align: calc_align(row.align, column.align)
            )
          else
            ComputedCell.new(
              cell, 
              calc_width(column.width, min_width), 
              :body,
              calc_align(row.align, column.align)
            )
          end
        end
    end

    def calc_width(column_width, min_width)
      case { column_width, min_width }
      when { Int32, Int32 }
        column_width > min_width ? column_width : min_width
      when { WidthOption::Auto, Int32 }
        min_width
      else
        min_width
      end
    end  

    def calc_align(cell_align, column_align)
      case { cell_align, column_align }
      when { Alignment, _ }
        cell_align
      when { AlignOption::Auto, Alignment}
        column_align
      else
        Alignment::Left
      end
    end
  end

  struct Joint
    getter :width

    def initialize(@type : String, @value : String = " ", @width : Int32 = 1)
    end

    def render(lookup = {} of String => String)
      lookup[@type].ljust(@width)
    end

    def height
      1
    end

    def inspect
      "(joint #{@type} #{@width.colorize(:green)})"
    end
  end

  struct Text
    getter :value, :align, :width

    def self.new(cell : ComputedCell)
      new(cell.value.to_s, cell.width, cell.align)
    end

    def initialize(@value : String, @width : Int32, @align : Alignment)
      @type = "text"
    end

    def value(line_num)
      @value.split("\n")[line_num]? || " " * @value.size 
    end

    def height
      @value.split("\n").size
    end

    def with_padding(value)
      String.build do |io|
        io << " " * PADDING_LEFT << value << " " * PADDING_RIGHT
      end
    end

    def with_align(value, align, width)
      case align
      when Alignment::Right
        value.rjust(width)
      when Alignment::Left
        value.ljust(width)
      when Alignment::Center
        value.center(width)
      end
    end

    def render(line_num : Int32 = 0)
      with_align(with_padding(value(line_num)), @align, @width)
    end

    def inspect
      "(text #{@width})"
    end
  end

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

  class NodeList
    include Enumerable(Node)

    def initialize(@nodes = Array(Node).new)
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
        end.map(&.as(Node))
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

  class AsciiRenderer < Renderer
    @@border_style = {
      "corner_top_left" => "+",
      "corner_top_right" => "+",
      "corner_bottom_right" => "+",
      "corner_bottom_left" => "+",
      "edge_top" => "-",
      "edge_right" => "|",
      "edge_bottom" => "-",
      "edge_left" => "|",
      "tee_top" => "+",
      "tee_right" => "+",
      "tee_bottom" => "+",
      "tee_left" => "+",
      "divider_vertical" => "|",
      "divider_horizontal" => "-",
      "joint_horizontal" => "-",
      "joint_vertical" => "|",
      "cross" => "+",
      "content" => " "
    }
  end  

  class MarkdownRenderer < Renderer
    @@border_style = {
      "corner_top_left" => "",
      "corner_top_right" => "",
      "corner_bottom_right" => "",
      "corner_bottom_left" => "",
      "edge_top" => "-",
      "edge_right" => "|",
      "edge_bottom" => "",
      "edge_left" => "|",
      "tee_top" => "",
      "tee_right" => "|",
      "tee_bottom" => "|",
      "tee_left" => "|",
      "divider_vertical" => "|",
      "divider_horizontal" => "-",
      "joint_horizontal" => "-",
      "joint_vertical" => "|",
      "cross" => "|",
      "content" => " "
    }    
  end  

  def self.table(border : Border = :top_bottom, &block)
    builder = TableBuilder.new(border)
    with builder yield
    builder
  end
end