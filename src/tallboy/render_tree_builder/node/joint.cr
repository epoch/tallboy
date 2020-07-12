module Tallboy
  struct Joint
    getter :width

    def initialize(@type : String, @value : String = " ", @width : Int32 = 1)
    end

    def render(lookup = {} of String => String)
      lookup[@type].ljust(@width)
    end

    def height
      1
    end

    def inspect
      "(joint #{@type} #{@width.colorize(:green)})"
    end
  end
end