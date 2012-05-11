module LogFileHandler

  def file_modified
    LogFile.reload_file_data(path)
  end

  def unbind
    EM.watch_file(path, LogFileHandler)
    LogFile.reload_file_data(path)
  end

  def restore_file
    EM.watch_file(@filename, LogFileHandler)
  end
end
