require "../spec_helper"

describe Tallboy::Cell do
  context "data is empty string" do

    cell = Tallboy::Cell.new("")

    describe "lines" do
      it "returns array with 1 empty string" do
        cell.lines.should eq [""]
      end
    end

    describe "size" do
      it "returns 0" do
        cell.size.should eq 0
      end
    end

    describe "line_have_content?" do
      it "line 0 returns true" do
        cell.line_exists?(0).should be_true
      end

      it "line 1 returns false" do
        cell.line_exists?(1).should be_false
      end
    end

  end

  context "data is single line string" do

    cell = Tallboy::Cell.new("cake pudding")

    describe "line_have_content?" do
      it "line 0 returns true" do
        cell.line_exists?(0).should be_true
      end

      it "line 1 returns false" do
        cell.line_exists?(1).should be_false
      end
    end
  end

  context "data is multi line string" do

    cell = Tallboy::Cell.new("cake\npudding")

    describe "line_have_content?" do
      it "line 0 returns true" do
        cell.line_exists?(0).should be_true
      end

      it "line 1 returns false" do
        cell.line_exists?(1).should be_true
      end
    end
  end  

end
