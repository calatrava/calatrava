require 'rspec/expectations'

module Web
  class CurrencyConversionScreen
    class << self
      def enter_amount(amount)
        $browser.text_field(:name => 'usd').set amount
      end

      def click_convert
        $browser.button(:name => 'submit-button').click
      end

      def expect_result(result)
        $browser.element(:xpath, "//div[@class='result']").text.should == result
      end
    end
  end
end