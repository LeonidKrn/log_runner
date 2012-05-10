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

  attr_reader :filename

  def initialize filename, procs, options = {}
    @@instances << self
    @filename = filename
    @file_group = parse_filename @filename
    @procs = procs
    @options = options
    @data_lines = []
    @parsed_data = []
    @last_parsed_data = []
  end

  def load_file_data
    data = File.read(filename) rescue ""
    data_lines = data.lines.to_a
    lines_diff = data_lines.length - @data_lines.length
    if lines_diff > 0
      new_data = data_lines.last(lines_diff)
      p new_data
      @data_lines = data_lines
      @last_parsed_data = parse_file_data(new_data)
      @parsed_data << @last_parsed_data
      @parsed_data.flatten!
    else
      @last_parsed_data = nil
    end
  end

  def parse_file_data(data)
    data.map do |line|
      time_str, data = line.split(":").first, line.split(":")[1..-1].join(":")
      date, time = time_str.split(",")
      time.gsub!("-", ":")
      {:time => Time.parse("#{date} #{time}"), :data => data}
    end
  end

  def parse_filename filename
  end

  def on_file_modification
    load_file_data
    @procs[:file_modification].(@last_parsed_data) if @last_parsed_data
  end
end

