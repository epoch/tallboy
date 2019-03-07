module Tallboy

  class Cell
    property :span, :data, :align

    def initialize(
      @data : CellValue = "" ,
      @span = 1,
      @align = Align::Left
    )
    end

    def lines
      @data.to_s.split("\n")
    end

    def size
      return 0 if span == 0
      lines.map(&.size).max / span
    end

    def pad_data(str, width, char)
      case align
      when Align::Left
        str.ljust(width, char)
      when Align::Right
        str.rjust(width, char)
      when Align::Center
        str
          .rjust(width / 2 + str.size / 2 + 1, char)
          .ljust(width, char)
      else
        str.ljust(width, char)
      end
    end

    def line_exists?(line_num)
      line_num < lines.size
    end
    
  end
end
