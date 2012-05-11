require 'digest'
class LogFile
  @@instances = []
  def self.reload_file_data filename
    @@instances.each do |i|
      if i.filename == filename
        i.on_file_modification
      end
    end
  end

  attr_reader :filename, :started

  def initialize filename, file_group, procs, options = {}
    @@instances << self
    @filename = filename
    @file_group = file_group
    @procs = procs
    @options = options
    @data_lines = []
    @parsed_data = []
    @last_parsed_data = []
    @started = false
    load_file_data
  end

  def start_watch
    EM.watch_file(@filename, LogFileHandler)
    @started = true
  end

  def file_data time = nil
    data = data_with_info(@parsed_data)[:data].dup
    if time
      data.select! do |d|
        (Time.now - d[:time]).to_i < time
      end
    end
    data_with_info(data)
  end

  def data_with_info data
    {file: @filename, group: @file_group, data: data}
  end

  def load_file_data
    data = File.read(filename) rescue ""
    data_lines = data.lines.to_a
    lines_diff = data_lines.length - @data_lines.length
    if lines_diff > 0
      new_data = data_lines.last(lines_diff)
      @data_lines = data_lines
      @last_parsed_data = parse_file_data(new_data)
      @parsed_data << @last_parsed_data
      @parsed_data.flatten!
    else
      @last_parsed_data = []
    end
  end

  def parse_file_data(data)
    data.map do |line|
      time_str, data = line.split(":").first, line.split(":")[1..-1].join(":")
      if time_str && data
        date, time = time_str.split(",")
        time.gsub!("-", ":")
        {:time => Time.parse("#{date} #{time}"), :data => data}
      end
    end.compact
  end

  def on_file_modification
    load_file_data
    @procs[:file_modification].(data_with_info(@last_parsed_data)) unless @last_parsed_data.empty?
  end
end

