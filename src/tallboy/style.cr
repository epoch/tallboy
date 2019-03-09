module Tallboy
  class Style
    getter :charset
    getter :left_padding_size
    getter :right_padding_size
    property :row_separator

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
