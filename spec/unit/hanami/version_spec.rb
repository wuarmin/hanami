# frozen_string_literal: true

RSpec.describe "Hanami::VERSION" do
  it "returns current version" do
    expect(Hanami::VERSION).to eq("2.2.1")
  end
end
