# frozen_string_literal: true

RSpec.describe RelatonEtsi do
  it "has a version number" do
    expect(RelatonEtsi::VERSION).not_to be nil
  end

  it "returs grammar hash" do
    hash = RelatonEtsi.grammar_hash
    expect(hash).to be_instance_of String
    expect(hash.size).to eq 32
  end
end
