class LogFile
  @@instances = []
  def self.reload_file_data filename
    @@instances.each do |i|
      i.on_file_modification(filename)
    end
  end

  def initialize filename, procs, options = {}
    @@instances << self
    @filename = filename
    @procs = procs
    @options = options
  end

  def on_file_modification filename
    procs[:file_modification].(filename)
  end
end

