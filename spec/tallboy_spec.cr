require "./spec_helper"

describe Tallboy do
  it "draws basic table" do
    table = Tallboy.table do
      header ["time", "activity"]
      row ["7:00", "breakfast"]
      row ["12:00", "lunch"]
      row ["3:00", "afternoon tea"]
      row ["6:30", "dinner"]
    end

    output = <<-IO
    ┌───────┬───────────────┐
    │ time  │ activity      │
    ├───────┼───────────────┤
    │ 7:00  │ breakfast     │
    │ 12:00 │ lunch         │
    │ 3:00  │ afternoon tea │
    │ 6:30  │ dinner        │
    └───────┴───────────────┘
    IO

    table.to_s.should eq(output)
  end

  it "draws table with column definitions" do
    table = Tallboy.table do
      columns(header: true) do
        add "name"
        add "hex"
        add "number of likes", align: :right
      end
    
      rows [
        ["mistyrose", "#ffe4e1", 1024],
        ["mintcream", "#f5fffa", 32],
        ["papayawhip", "#ffefd5", 128],
      ]
    end

    output = <<-IO
    ┌────────────┬─────────┬─────────────────┐
    │ name       │ hex     │ number of likes │
    ├────────────┼─────────┼─────────────────┤
    │ mistyrose  │ #ffe4e1 │            1024 │
    │ mintcream  │ #f5fffa │              32 │
    │ papayawhip │ #ffefd5 │             128 │
    └────────────┴─────────┴─────────────────┘
    IO

    table.to_s.should eq(output)    
  end

  it "draws advance table with column span and newlines" do
    resource = "dishes"
    table = Tallboy.table do
      columns do
        add "CRUD", width: 12
        add "http method"
        add "path"
      end

      header "good\nfood\nhunting", align: :center

      header do
        cell ""
        cell "routes", span: 2
      end

      header

      rows [
        ["create", "post", "/#{resource}"],
        ["read", "get", "/#{resource}"],
        ["update", "patch", "/#{resource}/:id"],
        ["destroy", "delete", "/#{resource}/:id"],
        ["read", "get", "/#{resource}/:id"],
        ["read", "get", "/#{resource}/:id/edit"],
        ["read", "get", "/#{resource}/new"],
      ]
    end

    output = <<-IO
    ┌─────────────────────────────────────────────┐
    │                    good                     │
    │                    food                     │
    │                   hunting                   │
    ├────────────┬────────────────────────────────┤
    │            │ routes                         │
    ├────────────┼─────────────┬──────────────────┤
    │ CRUD       │ http method │ path             │
    ├────────────┼─────────────┼──────────────────┤
    │ create     │ post        │ /dishes          │
    │ read       │ get         │ /dishes          │
    │ update     │ patch       │ /dishes/:id      │
    │ destroy    │ delete      │ /dishes/:id      │
    │ read       │ get         │ /dishes/:id      │
    │ read       │ get         │ /dishes/:id/edit │
    │ read       │ get         │ /dishes/new      │
    └────────────┴─────────────┴──────────────────┘
    IO

    table.to_s.should eq(output)    
  end
  
  it "draws markdown table" do
    table = Tallboy.table(border: :none) do
      header ["time", "activity"]
      row ["8:00 am", "breakfast"]
      row ["1:00 pm", "lunch"]
      row ["7:00 pm", "dinner"]
    end

    output = <<-IO
    | time    | activity  |
    |---------|-----------|
    | 8:00 am | breakfast |
    | 1:00 pm | lunch     |
    | 7:00 pm | dinner    |
    IO

    table.render(:markdown).to_s.should eq(output)
  end

  it "throws uneven columns execption" do
    table = Tallboy.table do
      row ["one"]
      row ["one", "two"]
    end

    expect_raises Tallboy::UnevenRowLength do
      table.render
    end
  end

end
