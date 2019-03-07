module Tallboy

  class Style
    getter :border_top
    getter :row
    getter :separator
    getter :border_bottom
    getter :left_padding_size
    getter :right_padding_size
    property :row_separator

    class Row
      getter :left, :pad, :mid, :right

      def initialize(
        @left : String, 
        @pad : String, 
        @mid : String, 
        @right : String)
      end

      def to_tuple
        {left, pad, mid, right}
      end
    end

    class BorderTop < Row end
    class BorderBottom < Row end
    class Separator < Row end

    def border_top=(chars)
      @border_top = BorderTop.new(*chars)
    end

    def border_bottom=(chars)
      @border_bottom = BorderBottom.new(*chars)
    end    

    def row=(chars)
      @row = Row.new(*chars)
    end

    def separator=(chars)
      @separator = Separator.new(*chars)
    end

    def padding_size=(size)
      @left_padding_size = size
      @right_padding_size = size
    end

    def padding_size(left_size, right_size)
      @left_padding_size, @right_padding_size = left_size, right_size 
    end

    def padding_size
      { @left_padding_size, @right_padding_size }
    end

    def initialize(
      border_top     = {"+", "-", "+", "+"},
      row            = {"|", " ", "|", "|"},
      separator      = {"+", "-", "+", "+"},
      border_bottom  = {"+", "-", "+", "+"},
      padding_size   = 1,
      @row_separator = false
      )

      @border_top = BorderTop.new(*border_top)
      @row = Row.new(*row)
      @separator = Separator.new(*separator)
      @border_bottom = BorderBottom.new(*border_bottom)
      @left_padding_size, @right_padding_size = padding_size, padding_size
    end

  end
end