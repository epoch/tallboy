class Layout
  include Enumerable(Int32)

  def initialize(@size : Int32, @value = [] of Int32)
    @value = Array.new(@size, 1) if @value.empty?
    p @value
  end

  def each
  end
end

class Row
  # getter :layout

  def initialize(size, layout = [] of Int32)
    @layout = Layout.new(size, layout)
  end

  def layout
    @layout
  end
end

Layout.new(3, [1,1,1])
Row.new(2, [1,1])
Row.new(4)

0.upto(3).each { |i| puts i }

3.times.each {|i| puts i }
3.times.map_with_index {|i, index| puts index }