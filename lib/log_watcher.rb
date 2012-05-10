load File.expand_path(File.join(File.dirname(__FILE__), "log_file_handler.rb"))
load File.expand_path(File.join(File.dirname(__FILE__), "log_file.rb"))
class LogWatcher

  def initialize dir, options = {}, &block
    @options = options
    @file_modification_proc = block
    LogFile.new(dir, {:file_modification => @file_modification_proc})
    EM.watch_file(dir, LogFileHandler)  
  end
  def reload_file_data file
    p self
    p file
    @file_modification_proc.(file: file)
  end
end
