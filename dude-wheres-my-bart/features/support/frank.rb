require 'frank-cucumber'
module IPhone
  def self.setup
    Frank::Cucumber::FrankHelper.use_shelley_from_now_on
  end

  def self.teardown
    #noop
  end

  def self.reset
    frank = Object.new.extend(Frank::Cucumber::FrankHelper).extend(Frank::Cucumber::Launcher)

    app_path = ENV['APP_BUNDLE_PATH'] || (defined?(APP_BUNDLE_PATH) && APP_BUNDLE_PATH)
    frank.launch_app app_path

    frank.app_exec( "setApiBaseUrl:", APP_BASE_URL )
  end
end
