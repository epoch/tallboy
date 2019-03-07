require "../spec_helper"

describe Tallboy::Style do

  style = Tallboy::Style.new

  describe "padding_size" do
    it "returns default size" do
      style.padding_size.should eq({ 1, 1 })
    end
  end

  describe "getters" do
    it "returns an object" do
      style.border_top.should be_truthy
      style.border_bottom.should be_truthy
      style.separator.should be_truthy
      style.row.should be_truthy
    end
  end

  describe "setters" do
    it "sets charater style" do
      style.border_top = {"x", "x", "x", "x"}
      style.border_bottom = {"x", "x", "x", "x"}
      style.separator = {"x", "x", "x", "x"}
      style.row = {"x", "x", "x", "x"}
      style.border_top.to_tuple.should eq({"x", "x", "x", "x"})
      style.border_bottom.to_tuple.should eq({"x", "x", "x", "x"})
      style.separator.to_tuple.should eq({"x", "x", "x", "x"})
      style.row.to_tuple.should eq({"x", "x", "x", "x"})
    end    
  end

  describe "CharSetting" do

    style = Tallboy::Style.new

    it "getters returns defaults" do
      style.separator.left.should eq("+")
      style.separator.pad.should eq("-")
      style.separator.mid.should eq("+")
      style.separator.right.should eq("+")
    end
    
    it "to_tuple returns character setting" do
      style.separator.to_tuple.should eq({"+", "-", "+", "+"})
    end    

  end


end