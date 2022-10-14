require "./lib/sql"

describe "sql" do
  it "selects constants" do
    expect(sql { SELECT 1 }).to eq("SELECT 1;")
    expect(sql { SELECT 1, 2 }).to eq("SELECT 1, 2;")
    expect(sql { SELECT 'Hello, world!' }).to eq("SELECT 'Hello, world!';")
  end

  it "selects from table" do
    expect(sql do
      SELECT column
      FROM table
    end).to eq("SELECT column FROM table;")
  end

  it "filters on qualified column" do
    expect(sql do
      SELECT column
      FROM table
      WHERE table.id = 123
    end).to eq("SELECT column FROM table WHERE id = 123;")
  end

  it "selects qualified column" do
    expect(sql do
      SELECT table.column
      FROM table
    end).to eq("SELECT table.column FROM table;")
  end

  it "filters with negation" do
    expect(sql do
      SELECT column
      FROM table
      WHERE table.id != 'xyz'
    end).to eq("SELECT column FROM table WHERE table.id != 'xyz';")
  end
end
