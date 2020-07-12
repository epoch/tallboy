module Tallboy
  struct Text
    getter :value, :align, :width

    def self.new(cell : ComputedCell)
      new(cell.value.to_s, cell.width, cell.align)
    end

    def initialize(@value : String, @width : Int32, @align : Alignment)
      @type = "text"
    end

    def value(line_num)
      @value.split("\n")[line_num]? || " " * @value.size 
    end

    def height
      @value.split("\n").size
    end

    def with_padding(value)
      String.build do |io|
        io << " " * PADDING_LEFT << value << " " * PADDING_RIGHT
      end
    end

    def with_align(value, align, width)
      case align
      when Alignment::Right
        value.rjust(width)
      when Alignment::Left
        value.ljust(width)
      when Alignment::Center
        value.center(width)
      end
    end

    def render(line_num : Int32 = 0)
      with_align(with_padding(value(line_num)), @align, @width)
    end

    def inspect
      "(text #{@width})"
    end
  end
end