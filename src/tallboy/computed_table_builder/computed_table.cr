module Tallboy
  class ComputedTable
    include Enumerable(ComputedRow)
    getter :border

    def initialize(@rows : Array(ComputedRow), @border : Border)
    end

    def each_row
      @rows.each_with_index do |row, idx|
        yield row, prev_row(idx), next_row(idx), idx
      end
    end

    def each(&block)
      @rows.each {|r| yield r }
    end

    def first
      @rows.first
    end

    def last
      @rows.last
    end  

    private def prev_row(idx)
      return nil if idx == 0
      @rows[idx - 1]
    end

    private def next_row(idx)
      @rows[idx + 1]?
    end  
  end
end