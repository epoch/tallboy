module Tallboy
  struct AutoSpanRow
    getter :align, :border, :value
    
    def initialize(@value : String, @align : AlignValue, @border : Border = :none)
    end

    def size() 1; end
  end
end