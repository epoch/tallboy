module Tallboy
  VERSION = "0.9.0"

  PADDING = 2

  alias ElemValue = String | Int32 | Float32 | Float64
  alias WidthValue = Int32 | WidthOption
  alias AlignValue = Alignment | AlignOption

  enum BorderStyle
    Ascii
    Unicode
    Markdown
  end

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

  class InvalidRowSize < Exception
  end

  class ColumnDefinitionRequired < Exception
  end

  class CellDefault
    getter :width, :align

    def initialize(
      @width : Int32,
      @align : AlignValue
    )
    end

    def merge(other_cell)
      CellDefault.new(@width + other_cell.width, @align)
    end
  end

  class ColumnDefinition
    getter :name, :width, :align

    def initialize(
      @name : String, 
      @width : WidthValue, 
      @align : AlignValue
    )
    end
  end  

  class ColumnDefinitionList
    include Enumerable(ColumnDefinition)
    include Iterable(ColumnDefinition)
    getter :columns

    def initialize
      @definitions = Array(ColumnDefinition).new
    end

    def add(
      name : String, 
      width : WidthValue = WidthOption::Auto, 
      align : AlignValue = AlignOption::Auto, 
    )
      @definitions << ColumnDefinition.new(
        name, 
        width, 
        align, 
      )
    end

    def build_cell_defaults(rows) : Array(CellDefault)
      if @definitions.empty? && !rows.empty?
        rows.first.each do |cell|
          add(cell.value)
        end
      end

      min_widths = ColumnWidthCalculator.new(self, rows).min_widths

      @definitions.zip(min_widths).map do |column, width|
        case column.width
        when WidthOption::Auto
          CellDefault.new(width, column.align)
        else
          if column.width.as(Int32) > width
            CellDefault.new(column.width.as(Int32), column.align)
          else
            CellDefault.new(width, column.align)
          end
        end
      end
    end

    def [](idx)
      @definitions[idx]
    end

    def each(&block)
      @definitions.each{ |definition| yield definition }
    end

    def each
      @definitions.each
    end
  end

  struct Cell
    enum Part
      Body
      Tail
    end

    getter :width, :align, :span, :part

    def initialize(
      @value : ElemValue, 
      @width : WidthValue = WidthOption::Auto, 
      @align : AlignValue = AlignOption::Auto,
      @span : Int32 = 1,
      @part : Part = :tail
    )
    end

    def value
      @value.to_s
    end

    def size
      (value.size / span).ceil.to_i
    end
  end

  class Row
    include Enumerable(Cell)
    getter :cells

    def self.new(arr : Array(ElemValue))
      new(arr.map {|elem| Cell.new(elem) })
    end

    def initialize(
      @cells = [] of Cell,
      @border_bottom : Bool = false,
      @border_top : Bool = false)
    end

    def border_bottom?
      @border_bottom
    end

    def border_top?
      @border_top
    end

    def cell(value, span : Int32 = 1, align : AlignValue = AlignOption::Auto)
      (span - 1).times do
        @cells << Cell.new(value, span: span, part: :body, align: align)
      end
      @cells << Cell.new(value, span: span, part: :tail, align: align)
    end

    def [](idx)
      @cells[idx]
    end

    def each
      @cells.each {|cell| yield cell }
    end

    def to_a
      @cells.map(&.value)
    end
  end

  class NodeBuilder
    def initialize(@type : NodeType, @cell : Cell, @cell_default : CellDefault)
    end
  
    def width : Int32
      case { @cell.width, @cell_default.width }
      when { Int32, _ }
        @cell.width.as(Int32)
      else
        @cell_default.width.as(Int32)
      end
    end
  
    def align : Alignment
      case { @cell.align, @cell_default.align }
      when { Alignment, _ }
        @cell.align.as(Alignment)
      when { AlignOption::Auto, Alignment }
        @cell_default.align.as(Alignment)
      when { AlignOption::Auto, AlignOption::Auto }
        Alignment::Left
      else
        Alignment::Left
      end
    end
  
    def build
      case @type
      when NodeType::Content
        ContentNode.new(@type, @cell.value, width, align, @cell.span)
      else
        DashNode.new(@type, @cell.value, width, @cell.span)
      end
    end
  end  

  enum NodeType
    CornerTopLeft
    CornerTopRight
    CornerBottomLeft
    CornerBottomRight
    EdgeTop
    EdgeRight
    EdgeBottom
    EdgeLeft
    TeeTop
    TeeRight
    TeeBottom
    TeeLeft
    DividerHorizontal
    DividerVertical
    JointHorizontal
    JointVertical
    Cross
    Content
  end

  class Node
    getter :type

    def initialize(@type : NodeType)
    end

    def height
      1
    end

    def render(char, line)
      char
    end
  end

  class DashNode < Node
    def initialize(@type : NodeType, @value : String, @width : Int32, @span : Int32)
    end

    def render(char, line)
      char.to_s * @width
    end
  end

  class ContentNode < Node
    def initialize(@type : NodeType, @value : String, @width : Int32, @align : Alignment, @span : Int32)
    end

    def with_padding(value)
      value.center(value.size + PADDING)
    end

    def height
      lines.size
    end

    def lines
      @value.to_s.split("\n")
    end

    def lines(num)
      lines[num]? || ""
    end

    def width(char)
      (char * (@span - 1)).size + @width - PADDING
    end

    def render(char, num)
      width = width(char)
      with_padding(
        case @align
        when Alignment::Right
          lines(num).rjust(width)
        when Alignment::Left
          lines(num).ljust(width)
        else
          lines(num).center(width)
        end
      )
    end
  end

  class RenderTable
    include Enumerable(Array(Array(Node)))

    def initialize(
      @rows : Array(Array(Node))
    )
    end

    def each
      @rows.each { |row| yield row }
    end

    def to_s(io : IO)
      io << BasicRenderer.new(self).render
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

    getter :table

    def initialize(
      @table : Array(NodeList),
      @border_style = {} of String => String
    )
      @border_style = @@border_style.merge(@border_style)
    end

    def render_node(node, i)
      node.render(@border_style[node.type.to_s.underscore], i)
    end

    def render(io = IO::Memory.new)
      table.each do |node_list|
        node_list.height.times do |i|
          line = node_list.map {|n| render_node(n, i) }.join
          io << line
          unless node_list == table.last && i == node_list.height - 1 || line.blank?
            io << "\n" 
          end
        end
      end
      io
    end
  end

  class MarkdownRenderer < Renderer
    @@border_style = {
      "corner_top_left" => "",
      "corner_top_right" => "",
      "corner_bottom_right" => "",
      "corner_bottom_left" => "",
      "edge_top" => "",
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

  class ColumnWidthCalculator
    def initialize(@column_def_list : ColumnDefinitionList, @rows : Array(Row))
      @rows.each do |row|
        unless row.size == @column_def_list.size
          raise InvalidRowSize.new(row.to_a.to_s) 
        end
      end
    end

    def min_widths
      @column_def_list.map_with_index do |_, idx|
        column(idx).map(&.size).max? ? column(idx).map(&.size).max + PADDING : 0
      end
    end

    private def content_rows
      @rows.select(&.is_a?(Row)).map(&.as(Row))
    end    

    private def column(idx)
      content_rows.map {|row| row[idx] }
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

  class RenderListBuilder
    def initialize(@table : TableBuilder)
      @cell_defaults = @table.column_def_list.build_cell_defaults(@table.rows).as(Array(CellDefault))
    end

    def build_border(prev_row, next_row)
      case { prev_row, next_row }
      when { Nil, Row }
        border_top(next_row)
      when { Row, Nil }
        border_bottom(prev_row)
      when { Row, Row }
        border_middle(prev_row, next_row)
      else
        raise "just one row???"
      end
    end

    def border_top(row)
      build_nodes(:corner_top_left, :corner_top_right, :tee_top, :edge_top, :joint_horizontal, row)
    end

    def border_bottom(row)
      build_nodes(:corner_bottom_left, :corner_bottom_right, :tee_bottom, :edge_bottom, :joint_horizontal, row)
    end

    def border_middle(row_a, row_b)
      build_nodes(:tee_left, :tee_right, :cross, :divider_horizontal, :joint_horizontal, row_a, row_b)
    end    

    private def build_nodes(
      left : NodeType, 
      right : NodeType, 
      cross : NodeType, 
      edge : NodeType,
      divider : NodeType, 
      row_a, 
      row_b = row_a
    )
      nodes = NodeList.new
      nodes << Node.new(left)

      @cell_defaults.each_with_index do |default, idx|
        nodes << NodeBuilder.new(edge, row_a[idx], default).build
        next if idx == @cell_defaults.size - 1

        case { row_a[idx].part, row_b[idx].part }
        when { Cell::Part::Tail, Cell::Part::Body }
          nodes << Node.new(:tee_bottom)
        when { Cell::Part::Body, Cell::Part::Tail }          
          nodes << Node.new(:tee_top)
        when { Cell::Part::Body, Cell::Part::Body }
          nodes << Node.new(divider)
        when { Cell::Part::Tail, Cell::Part::Tail }
          nodes << Node.new(cross)
        end
      end
      nodes << Node.new(right)    
      nodes    
    end
    
    def build_content_row(row)
      nodes = NodeList.new
      nodes << Node.new(:edge_left)

      cells = [] of Cell
      defaults = [] of CellDefault

      row.zip(@cell_defaults).each_with_index do |(cell, default), idx|

        case cell.part
        when Cell::Part::Body
          defaults << default
        when Cell::Part::Tail
          defaults << default
          
          default = defaults.reduce do |cell, curr_cell|
            cell.merge(curr_cell)
          end

          defaults = [] of CellDefault

          nodes << NodeBuilder.new(:content, cell, default).build
          nodes << Node.new(:divider_vertical) unless idx == row.size - 1
        end
      end

      nodes << Node.new(:edge_right)
      nodes
    end

    def build
      render_tree = [] of NodeList

      @table.each_row do |row, prev_row, next_row, i|
        if row.border_top? || i == 0
          render_tree << build_border(prev_row, row)
        end
        
        render_tree << build_content_row(row)

        if row.border_bottom? || i == @table.rows.size - 1
          render_tree << build_border(row, next_row)
        end
      end

      render_tree
    end
  end

  class TableBuilder
    getter :rows, :column_def_list

    def self.new(&block)
      instance = new
      with instance yield
      instance
    end

    def initialize
      @column_def_list = ColumnDefinitionList.new
      @rows = [] of Row
    end

    def define_columns(auto_header = false, &block)
      with @column_def_list yield
      header(@column_def_list.map(&.name)) if auto_header
      self
    end

    def auto_header
      header(@column_def_list.map(&.name))
    end

    def header(row : Array(ElemValue))
      @rows << Row.new(row.map {|c| Cell.new(c) }, border_bottom: true)
    end

    def header(content : String, align : AlignValue = AlignOption::Auto)
      @rows << Row.new(cells(content, align), border_bottom: true)
    end

    def header(&block)
      row = Row.new(border_bottom: true)
      with row yield
      @rows << row
    end   
    
    def footer(content : String, align : AlignValue = AlignOption::Auto)
      @rows << Row.new(cells(content, align), border_top: true)
    end

    def footer(row : Array(ElemValue))
      @rows << Row.new(row.map {|c| Cell.new(c) }, border_top: true)
    end

    def footer(&block)
      row = Row.new(border_top: true)
      with row yield
      @rows << row
    end

    def row(row : Array(ElemValue), border_bottom = false, border_top = false)
      @rows << Row.new(row.map {|e| Cell.new(e) }, border_bottom, border_top)
    end

    def row(content : String)
      @rows << Row.new(cells(content))
    end

    def row(&block)
      row = Row.new
      with row yield
      @rows << row
    end    
    
    def rows(rows : Array(Array(ElemValue)), divider_frequency : Int32 = 0)
      body(rows, divider_frequency)
    end

    def body(rows : Array(Array(ElemValue)), divider_frequency : Int32 = 0)
      rows.each_with_index do |row, idx|
        if divider_frequency > 0 && (idx+1).divisible_by?(divider_frequency)
          header(row)
        else
          row(row)
        end
      end
    end

    private def cells(content, align : AlignValue = AlignOption::Auto)
      if @column_def_list.empty?
        raise ColumnDefinitionRequired.new("row \"#{content}\" requires column definition") 
      end

      cells = [] of Cell
      (@column_def_list.size - 1).times do
        cells << Cell.new(
          content, 
          align: align, 
          part: :body, 
          span: @column_def_list.size)
      end
      cells << Cell.new(content, part: :tail, span: @column_def_list.size)
    end

    private def prev_row(idx)
      return nil if idx == 0
      @rows[idx - 1]
    end

    private def next_row(idx)
      @rows[idx + 1]?
    end

    def each_row(&block)
      @rows.each_with_index do |row, idx|
        yield row, prev_row(idx), next_row(idx), idx
      end
    end

    def to_s(io)
      Renderer.new(self.build).render(io)
    end
      
    def build
      RenderListBuilder.new(self).build
    end    

    def render(border_style : BorderStyle = :unicode, io = IO::Memory.new)
      case border_style
      when BorderStyle::Ascii
        AsciiRenderer.new(self.build).render(io)
      when BorderStyle::Markdown
        MarkdownRenderer.new(self.build).render(io)
      when BorderStyle::Unicode
        Renderer.new(self.build).render(io)
      end
    end
  end  

  def self.table(&block)
    builder = TableBuilder.new
    with builder yield
    builder
  end
end