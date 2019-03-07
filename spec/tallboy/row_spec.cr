require "../spec_helper"

describe Tallboy::Row do
  describe "when data size and layout does not match" do
  end

  context "when data are single char strings" do
    data = ["a", "b", "c"]

    describe "new" do
      it "raise exception when data size does not match layout" do
        expect_raises(Tallboy::InvalidLayoutException) do
          Tallboy::Row.new(data, layout: [4,0,0,0])    
        end
      end
    end

    describe "map" do
      it "can enumerate with map" do
        row = Tallboy::Row.new(data, layout: [3,0,0])
        row.map(&.data).should eq(["a","b","c"])
      end
    end

    describe "layout" do
      it "returns spans" do
        row = Tallboy::Row.new(data, layout: [3,0,0])
        row.layout.size.should eq(3)
      end
    end

    # describe "render" do
    #   it "generate string with default border & padding" do
    #     row = Tallboy::Row.new(data)
    #     row.render([1,1,1]).chomp.should eq("| a | b | c |")
    #   end

    #   it "generates string with custom style" do
    #     style = Tallboy::Style.new
    #     style.row = {"x","-","+","x"}
    #     row = Tallboy::Row.new(data)
    #     row.render([1,1,1], style: style).chomp.should eq("x-a-+-b-+-c-x")
    #   end

    #   context "when layout is 3 0 0" do 
    #     it "render cell with spans" do
    #       row = Tallboy::Row.new(data)
    #       row.layout = [3,0,0]
    #       row.render([1,1,1,1]).chomp.should eq("| a         |")
    #     end
    #   end
    # end
  end

  context "when data contains new line" do

    data = ["a", "b\ne\ne", "c\nd"]
    table = Tallboy::Row.new(data)

    describe "height" do
      it "returns max lines" do
        table.height.should eq(3)
      end
    end

    # describe "render_line" do
    #   it "renders first line" do
    #     table.render_line(0, [1,1,1]).chomp.should eq("| a | b | c |")
    #   end

    #   it "renders second line" do
    #     table.render_line(1, [1,1,1]).chomp.should eq("|   | e | d |")
    #   end 
      
    #   it "renders third line" do
    #     table.render_line(2, [1,1,1]).chomp.should eq("|   | e |   |")
    #   end     
    # end
  end

end
