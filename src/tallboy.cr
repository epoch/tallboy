module Tallboy
  VERSION = "0.9.0"

  PADDING = 2

  alias ElemValue = String | Int32 | Float32 | Float64
  alias WidthValue = Int32 | WidthOption
  alias AlignValue = Alignment | AlignOption

  enum Preset
    Classic
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

    def concat(other_cell)
      CellDefault.new(@width + 1 + other_cell.width, @align)
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

      min_widths = ColumnWidthChecker.new(self, rows).min_widths

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

    def concat(other_cell)
      Cell.new(@value, @width, @align, @span, @part)
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
    def self.new(type : NodeType, arr : Array({Cell, CellDefault}))
    end

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
        ContentNode.new(@type, @cell.value, width, align)
      else
        DashNode.new(@type, @cell.value, width)
      end
    end
  end  

  enum NodeType
    TopLeft
    TopMid
    TopRight
    Top
    MidLeft
    MidMid
    MidRight
    Mid
    BottomLeft
    BottomMid
    BottomRight
    Bottom
    ContentLeft
    ContentMid
    ContentRight
    Content
    Space
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
    def initialize(@type : NodeType, @value : String, @width : Int32)
    end

    def render(char, line)
      char.to_s * @width
    end
  end

  class ContentNode < Node
    def initialize(@type : NodeType, @value : String, @width : Int32, @align : Alignment)
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

    def render(char, num)
      with_padding(
        case @align
        when Alignment::Right
          (lines[num]? || "").rjust(@width - PADDING)
        when Alignment::Left
          (lines[num]? || "").ljust(@width - PADDING)
        else
          (lines[num]? || "").center(@width - PADDING)
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

  class BasicRenderer
    @@charset = {
      "dash" => "─",
      "content_left" => "│",
      "content_right" => "│",
      "content_mid" => "│",
      "content" => "",
      "top_left" => "┌",
      "top_right" => "┐",
      "top_mid" => "┬",
      "top" => "─",
      "bottom_left" => "└",
      "bottom_right" => "┘",
      "bottom_mid" => "┴",
      "bottom" => "─",
      "mid_left" => "├",
      "mid_right" => "┤",
      "mid_mid" => "┼",
      "mid" => "─"
    }

    getter :table

    def initialize(
      @table : Array(NodeList),
      @charset = {} of String => String
    )
      @charset = @@charset.merge(@charset)
    end

    def render_node(node, i)
      node.render(@charset[node.type.to_s.underscore], i)
    end

    def render(io = IO::Memory.new)
      table.each do |node_list|
        node_list.height.times do |i|
          io << node_list.map {|n| render_node(n, i) }.join 
          unless node_list == table.last && i == node_list.height - 1
            io << "\n" 
          end
        end
      end
      io
    end
  end

  class MarkdownRenderer < BasicRenderer
    @@charset = {
      "dash" => "-",
      "content_left" => "|",
      "content_right" => "|",
      "content_mid" => "|",
      "content" => "",
      "top_left" => "|",
      "top_right" => "|",
      "top_mid" => "-",
      "top" => "-",
      "bottom_left" => "|",
      "bottom_right" => "|",
      "bottom_mid" => "-",
      "bottom" => "-",
      "mid_left" => "|",
      "mid_right" => "|",
      "mid_mid" => "|",
      "mid" => "-"
    }

    def table
      @table[1..-2]
    end
  end

  class ClassicRenderer < BasicRenderer
    @@charset = {
      "dash" => "-",
      "content_left" => "|",
      "content_right" => "|",
      "content_mid" => "|",
      "content" => "",
      "top_left" => "+",
      "top_right" => "+",
      "top_mid" => "+",
      "top" => "-",
      "bottom_left" => "+",
      "bottom_right" => "+",
      "bottom_mid" => "+",
      "bottom" => "-",
      "mid_left" => "+",
      "mid_right" => "+",
      "mid_mid" => "+",
      "mid" => "-"
    }
  end

  class ColumnWidthChecker
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

  class RenderNodesBuilder
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
      build_nodes(:top_left, :top_right, :top_mid, row)
    end

    def border_bottom(row)
      build_nodes(:bottom_left, :bottom_right, :bottom_mid, row)
    end

    def border_middle(row_a, row_b)
      build_nodes(:mid_left, :mid_right, :mid_mid, row_a, row_b)
    end    

    private def build_nodes(left : NodeType, right : NodeType, mid_mid : NodeType, row_a, row_b = row_a)
      nodes = NodeList.new
      nodes << Node.new(left)

      @cell_defaults.each_with_index do |default, idx|
        nodes << NodeBuilder.new(:mid, row_a[idx], default).build
        next if idx == @cell_defaults.size - 1

        case { row_a[idx].part, row_b[idx].part }
        when { Cell::Part::Tail, Cell::Part::Body }
          nodes << Node.new(:bottom_mid)
        when { Cell::Part::Body, Cell::Part::Tail }          
          nodes << Node.new(:top_mid)
        when { Cell::Part::Body, Cell::Part::Body }
          nodes << Node.new(:mid)
        else
          nodes << Node.new(mid_mid)
        end
      end
      nodes << Node.new(right)    
      nodes    
    end
    
    def build_content_row(row)
      nodes = NodeList.new
      nodes << Node.new(:content_left)

      cells = [] of Cell
      defaults = [] of CellDefault

      row.zip(@cell_defaults).each_with_index do |(cell, default), idx|

        case cell.part
        when Cell::Part::Body
          cells << cell          
          defaults << default
        when Cell::Part::Tail
          cells << cell
          defaults << default
          
          cell = cells.reduce do |cell, curr_cell|
            cell.concat(curr_cell)
          end

          default = defaults.reduce do |cell, curr_cell|
            cell.concat(curr_cell)
          end

          cells = [] of Cell
          defaults = [] of CellDefault

          nodes << NodeBuilder.new(:content, cell, default).build
          nodes << Node.new(:content_mid) unless idx == row.size - 1
        end
      end

      nodes << Node.new(:content_right)
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

    def initialize
      @column_def_list = ColumnDefinitionList.new
      @rows = [] of Row
    end

    def header
      header(@column_def_list.map(&.name))
    end

    def auto_header
      header(@column_def_list.map(&.name))
    end

    def define_columns(auto_header = false, &block)
      with @column_def_list yield
      header(@column_def_list.map(&.name)) if auto_header
      self
    end

    def header(row : Array(ElemValue))
      @rows << Row.new(row.map {|c| Cell.new(c) }, border_bottom: true)
    end

    def header(content : String, align : AlignValue = AlignOption::Auto)
      cells = row(content, align)
      @rows << Row.new(cells, border_bottom: true)
    end

    def header(&block)
      row = Row.new(border_bottom: true)
      with row yield
      @rows << row
    end   
    
    def footer(content : String, align : AlignValue = AlignOption::Auto)
      cells = row(content, align)
      @rows << Row.new(cells, border_top: true)
    end

    def footer(row : Array(ElemValue))
      @rows << Row.new(row.map {|c| Cell.new(c) }, border_top: true)
    end

    def footer(&block)
      row = Row.new(border_top: true)
      with row yield
      @rows << row
    end      

    def body(rows : Array(Array(ElemValue)))
      rows[0..-2].each do |row|
        row(row)
      end
      row(rows.last)
    end

    def row(content, align : AlignValue = AlignOption::Auto)
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

    def row(row : Array(ElemValue))
      @rows << Row.new(row)
    end

    def row(&block)
      row = Row.new
      with row yield
      @rows << row
    end

    def prev_row(idx)
      return nil if idx == 0
      @rows[idx - 1]
    end

    def next_row(idx)
      @rows[idx + 1]?
    end

    def each_row(&block)
      @rows.each_with_index do |row, idx|
        yield row, prev_row(idx), next_row(idx), idx
      end
    end

    def to_s(io)
      BasicRenderer.new(self.build).render(io)
    end
      
    def build
      RenderNodesBuilder.new(self).build
    end    

    def render(preset : Preset = :unicode, io = IO::Memory.new)
      case preset
      when Preset::Classic
        ClassicRenderer.new(self.build).render(io)
      when Preset::Markdown
        MarkdownRenderer.new(self.build).render(io)
      when Preset::Unicode
        BasicRenderer.new(self.build).render(io)
      end
    end
  end  

  def self.table(&block)
    builder = TableBuilder.new
    with builder yield
    builder
  end
end