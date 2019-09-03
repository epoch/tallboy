module Tallboy
  class Cell
    property :span, :data
    getter :align

    def initialize(
      @data : CellValue = "",
      @span = 1,
      @align = Align::Left
    )
    end

    def align(align : Align)
      @align = align
    end

    def align=(align : Align)
      @align = align
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
      when .left?
        str.ljust(width, char)
      when .right?
        str.rjust(width, char)
      when .center?
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

    def wrap_text(wrap_by : Symbol, max_line_size : Int32)
      case wrap_by
      when :char
        if max_line_size > 0
          chars = @data.to_s.chars
          wrapped_data = ""
          chars.each_slice(max_line_size) { |slice| wrapped_data += slice.join("") + "\n" }
          @data = wrapped_data.chomp("\n")
        end
      when :word
        if max_line_size > 0
          words = @data.to_s.gsub(/(\ |\n|\t){1,}/, " ").split(" ")
          wrapped_data = ""

          row_size = 0
          words.each do |w|
            raise "Word wrapping failed, '#{w}' (#{w.size}) is bigger than max line size (#{max_line_size})" if w.size > max_line_size
            row_size += w.size
            if row_size < max_line_size
              wrapped_data += "#{w} "
            else
              wrapped_data += "\n#{w} "
              row_size = 0
            end
          end

          @data = wrapped_data.chomp(" ")
        end
      else
        raise "Unknown wrapping type, use ':char' or ':word'"
      end
    end
  end
end
