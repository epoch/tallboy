module Tallboy
  struct Text
    delegate value, to: @cell
    delegate width, to: @cell
    delegate align, to: @cell

    def initialize(@cell : ComputedCell)
      @type = "text"
    end

    def value(line_num)
      value.lines[line_num]? || blank_line
    end

    def height
      value.lines.size
    end

    def blank_line
      " " * value.size 
    end

    def with_padding(value)
      String.build do |io|
        io << " " * PADDING_LEFT << value << " " * PADDING_RIGHT
      end
    end

    def with_align(text, align, width)
      width += escaped_codes_size(text)

      case align
      when Alignment::Right
        text.rjust(width)
      when Alignment::Left
        text.ljust(width)
      when Alignment::Center
        text.center(width)
      end
    end

    def render(line_num : Int32 = 0)
      with_align(with_padding(value(line_num)), align, width)
    end

    private def escaped_codes_size(text)
      text.size - text.gsub(/\e\[[0-9;]*m/, "").size
    end

    def inspect
      "(text #{@width})"
    end
  end
end