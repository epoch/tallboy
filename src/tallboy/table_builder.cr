require "./table_builder/*"

module Tallboy
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

    def row(arr : Array, border : Border = :none)
      @rows << Row.new(arr.map {|elem| Cell.new(elem.to_s) }, border)
    end

    def row(value, align : AlignValue = :auto, border : Border = :none)
      @rows << AutoSpanRow.new(value.to_s, align, border)
    end

    def row(border : Border = :none, &block)
      row = Row.new(border: border)
      with row yield
      @rows << row
    end

    def rows(rows : Array(Array))
      rows.each do |row|
        row(row)
      end
    end

    def header(arr : Array)
      row(arr, Border::Bottom)
    end

    def header(value, align : AlignValue = :auto)
      row(value.to_s, align: align, border: :bottom)
    end

    def header(&block)
      row = Row.new(border: :bottom)
      with row yield
      @rows << row
    end

    def footer(arr : Array)
      row(arr, Border::Top)
    end

    def footer(value, align : AlignValue = :auto)
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

      if @rows.select(&.is_a?(Row)).any? { |r| r.size != @columns.size}
        raise UnevenRowLength.new 
      end

      RenderTreeBuilder.new(
        ComputedTableBuilder.new(self).build
      ).build
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

    def to_s(io)
      Renderer.new(self.build).render(io)
    end
  end
end