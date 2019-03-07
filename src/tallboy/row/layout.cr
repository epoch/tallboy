module Tallboy
  class Row
    class Layout
      include Enumerable(Int32)
      getter :spans
      
      def initialize(@column_count : Int32, @spans = [] of Int32)
        @spans = Array.new(@column_count, 1) if @spans.empty?
        raise InvalidLayoutException.new if !valid?
      end

      def each
        spans.each { |span| yield(span) }
      end    

      def valid?
        @column_count == spans.sum
      end
    end
  end
end