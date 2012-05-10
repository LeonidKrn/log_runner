require 'yaml'
require 'sinatra'
require 'eventmachine'
require 'em-websocket'
require 'json'
require 'sinatra/async'

load File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "log_watcher.rb"))
load File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "log_file.rb"))

EM.run do
  @config = YAML::load File.read(File.expand_path(File.join(File.dirname(__FILE__), "..", "config", "log_runner.yml")))
  class LogRunner < Sinatra::Base

    get "/" do
    end
  end
  EM::WebSocket.start(:host => '0.0.0.0', :port => 9345) do |websocket|
    LogWatcher.new(@config["path"], @config) do |data|
      websocket.send(data.to_json)
    end
    websocket.onopen { puts "Client connected" }

    websocket.onmessage do |msg|
      websocket.send({:type => 'location', :lat => 456, :lng => 123}.to_json)

    end

    websocket.onclose { puts "closed" }
    websocket.onerror { |e| puts "err #{e.inspect}" }

  end
  LogRunner.run!(:port => 4567)
end
