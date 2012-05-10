module LogFileHandler

  def file_modified
    p "1"
    LogFile.reload_file_data(path)
  end

  def file_moved
    p "2"
  end

  def file_deleted
    p "3"
  end

  def unbind
    p "4"
  end
end
