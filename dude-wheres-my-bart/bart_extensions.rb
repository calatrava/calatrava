require 'bart/station'

module Bart
  class Station
    def self.with_abbr(abbr)
      return nil unless ID_TO_NAME.has_key?( abbr )
      return self.new(abbr)
    end
  end

  class Estimate
    attr_reader :color

    def initialize(xml)
      document = Nokogiri::XML.parse(xml)

      @minutes   = document.css('minutes').text.to_i
      @platform  = document.css('platform').text.to_i
      @direction = document.css('direction').text
      @length    = document.css('length').text.to_i
      @color     = document.css('color').text
    end
  end
end
