def choose_platform_layer( platform )
  platform_namespace = case platform
  when /^web$/i
    Web
  else
    raise 'unrecognized platform'
  end

  Object.const_set( 'Device', platform_namespace )
end

AfterConfiguration do
  choose_platform_layer( ENV['PLATFORM'] || 'web' )
  Device.setup
end

at_exit do
  Device.teardown
end