module Tallboy
  class Style
    getter :charset
    getter :left_padding_size
    getter :right_padding_size
    property :row_separator

    struct Charset
      struct CharRow
        getter :left, :pad, :mid, :right

        def initialize(
          @left : String,
          @pad : String,
          @mid : String,
          @right : String
        )
        end

        def to_tuple
          {left, pad, mid, right}
        end
      end

      getter :border_bottom, :border_top, :separator, :row

      def initialize(border_top, row, separator, border_bottom)
        @border_top = CharRow.new(*border_top)
        @border_bottom = CharRow.new(*border_bottom)
        @row = CharRow.new(*row)
        @separator = CharRow.new(*separator)
      end

      def row=(row)
        @row = CharRow.new(*row)
      end

      def separator=(separator)
        @separator = CharRow.new(*separator)
      end

      def border_bottom=(border_bottom)
        @border_bottom = CharRow.new(*border_bottom)
      end

      def border_top=(border_top)
        @border_top = CharRow.new(*border_top)
      end
    end

    def padding_size=(size)
      @left_padding_size = size
      @right_padding_size = size
    end

    def padding_size(left_size, right_size)
      @left_padding_size, @right_padding_size = left_size, right_size
    end

    def padding_size
      {@left_padding_size, @right_padding_size}
    end

    def initialize(
      charset = ASCII,
      padding_size = 1,
      @row_separator = false
    )
      @charset = Charset.new(**charset)
      @left_padding_size, @right_padding_size = padding_size, padding_size
    end
  end
end
