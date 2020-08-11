require "./spec_helper"

Text = Tallboy::Text

describe Text do
  it "aligns left" do
    text = Text.new(Tallboy::ComputedCell.new("test", 10))
    text.render.should eq(" test     ")
  end

  it "renders properly with escape codes" do
    text = Text.new(Tallboy::ComputedCell.new("\e[31mtest\e[0m", 10))
    text.render.should eq(" \e[31mtest\e[0m     ")
  end

  it "renders multi line properly with escape codes" do
    text = Text.new(Tallboy::ComputedCell.new("\e[31mhi\e[0m\nthere", 10))
    text.render.should eq(" \e[31mhi\e[0m       ")
    text.render(1).should eq(" there    ")
  end  

  it "single line value with line number" do
    text = Text.new(Tallboy::ComputedCell.new("test", 10))
    text.value(0).should eq("test")
    text.value(1).should eq("    ")
  end

  it "multi line value with line number" do
    text = Text.new(Tallboy::ComputedCell.new("hi\nthere", 10))
    text.value(0).should eq("hi")
    text.value(1).should eq("there")
  end

end