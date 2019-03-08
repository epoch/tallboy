require "../spec_helper"

describe Tallboy::Style do
  style = Tallboy::Style.new

  describe "padding_size" do
    it "returns default size" do
      style.padding_size.should eq({1, 1})
    end
  end

  describe "getters" do
    it "returns an object" do
      style.charset.border_top.should be_truthy
      style.charset.border_bottom.should be_truthy
      style.charset.separator.should be_truthy
      style.charset.row.should be_truthy
    end
  end

  describe "setters" do
    it "sets charater style" do
      style.charset.border_top = {"x", "x", "x", "x"}
      style.charset.border_bottom = {"x", "x", "x", "x"}
      style.charset.separator = {"x", "x", "x", "x"}
      style.charset.row = {"x", "x", "x", "x"}
      style.charset.border_top.to_tuple.should eq({"x", "x", "x", "x"})
      style.charset.border_bottom.to_tuple.should eq({"x", "x", "x", "x"})
      style.charset.separator.to_tuple.should eq({"x", "x", "x", "x"})
      style.charset.row.to_tuple.should eq({"x", "x", "x", "x"})
    end
  end

  describe "CharSetting" do
    style = Tallboy::Style.new

    it "getters returns defaults" do
      style.charset.separator.left.should eq("+")
      style.charset.separator.pad.should eq("-")
      style.charset.separator.mid.should eq("+")
      style.charset.separator.right.should eq("+")
    end

    it "to_tuple returns character setting" do
      style.charset.separator.to_tuple.should eq({"+", "-", "+", "+"})
    end
  end
end
