require "./tallboy/exception/*"
require "./tallboy/*"
require "./tallboy/renderer"
require "./tallboy/renderer/*"

module Tallboy
  VERSION = "0.9.1"

  PADDING_LEFT = 1
  PADDING_RIGHT = 1

  alias WidthValue = Int32 | WidthOption
  alias AlignValue = Alignment | AlignOption

  enum Alignment
    Left
    Right
    Center
  end

  enum AlignOption
    Auto
  end

  enum WidthOption
    Auto
  end

  enum Border
    None
    Top
    Bottom
    TopBottom

    def top?
      self == Border::Top || self == Border::TopBottom
    end

    def bottom?
      self == Border::Bottom || self == Border::TopBottom
    end
  end

  enum BorderStyle
    Ascii
    Unicode
    Markdown
  end

  def self.table(border : Border = :top_bottom, &block)
    builder = TableBuilder.new(border)
    with builder yield
    builder
  end
end