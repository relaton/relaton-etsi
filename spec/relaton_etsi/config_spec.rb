describe RelatonEtsi do
  after { RelatonEtsi.instance_variable_set :@configuration, nil }

  it "configure" do
    RelatonEtsi.configure do |conf|
      conf.logger = :logger
    end
    expect(RelatonEtsi.configuration.logger).to eq :logger
  end
end
