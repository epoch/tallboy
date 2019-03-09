module Tallboy
  class Style
    struct Charset
      getter :border_bottom, :border_top, :separator, :row
      
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
  end
end