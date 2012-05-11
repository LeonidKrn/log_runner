require 'yaml'
require 'sinatra'
require 'eventmachine'
require 'em-websocket'
require 'json'
require 'sinatra/async'

load File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "log_watcher.rb"))
load File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "log_file.rb"))

EM.run do
  @@config = YAML::load File.read(File.expand_path(File.join(File.dirname(__FILE__), "..", "config", "log_runner.yml")))
  @@log_watcher = LogWatcher.new(@@config["path"], @@config)
  class LogRunner < Sinatra::Base
    set :public, 'public'

    get "/tests" do
      time = params[:time].to_i
      time = 3600 if time==0
      @logs_data = @@log_watcher.logs_data(time)
      p @logs_data
      haml :tests
    end

    post "/run_tests" do
      %x{/usr/local/ruby/1.9.2/bin/ruby #{@@config["script_path"]}}
    end
  end
  EM::WebSocket.start(:host => '0.0.0.0', :port => 9345) do |websocket|
    @@log_watcher.on_file_modification do |data|
      websocket.send(data.to_json)
    end
    @@log_watcher.start_watch
    websocket.onopen { puts "Client connected" }

    websocket.onmessage do |msg|
      websocket.send({:type => 'location', :lat => 456, :lng => 123}.to_json)
    end

    websocket.onclose { puts "closed" }
    websocket.onerror { |e| puts "err #{e.inspect}" }

  end
  LogRunner.run!(:port => 4567)
end
