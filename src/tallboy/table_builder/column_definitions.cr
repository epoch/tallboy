module Tallboy
  record ColumnDefinition, 
    name : String = "", 
    width : WidthValue = :auto, 
    align : AlignValue = :auto


  class ColumnDefinitions
    include Enumerable(ColumnDefinition)
    getter :columns

    def self.new(column_count : Int32)
      new(Array.new(column_count, ColumnDefinition.new))
    end

    def initialize(@columns = [] of ColumnDefinition)
    end

    def add(name, width : WidthValue = WidthOption::Auto, align : AlignValue = :auto)
      @columns << ColumnDefinition.new(name, width, align)
    end

    def each
      @columns.each {|c| yield c }
    end
  end
end