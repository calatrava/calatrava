require File.expand_path( File.join( File.dirname(__FILE__), '..','..','dwmb' ) )

APP_PORT = 9999
APP_BASE_URL = "http://localhost:#{APP_PORT}/"

$app = Sinatra::Application

$app_thread = Thread.fork do
  Rack::Server.start( :app => $app, :Port => APP_PORT, :AccessLog => [] )
end


