load File.expand_path(File.join(File.dirname(__FILE__), "log_file_handler.rb"))
class LogWatcher
  @@instances = []
  def self.reload_file_data filename
    @@instances.each do |i|
      i.reload_file_data(filename)
    end
  end
  def initialize dir, options = {}, &block
    @@instances << self
    @options = options
    @file_modification_proc = block
    EM.watch_file(dir, LogFileHandler)  
  end
  def reload_file_data file
    p self
    p file
    @file_modification_proc.(file: file)
  end
end
