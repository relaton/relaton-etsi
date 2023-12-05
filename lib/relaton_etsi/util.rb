module RelatonEtsi
  module Util
    extend RelatonBib::Util

    def self.logger
      RelatonEtsi.configuration.logger
    end
  end
end
