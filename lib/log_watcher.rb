load File.expand_path(File.join(File.dirname(__FILE__), "log_file_handler.rb"))
load File.expand_path(File.join(File.dirname(__FILE__), "log_file.rb"))
class LogWatcher

  DEFAULT_OPTIONS = {ext: "log", group_sequence: [:host, :test_case, :date]}
  def initialize dir, options = {}
    @dir = dir
    @options = DEFAULT_OPTIONS.merge options
    @log_files = []
    @procs = {}
    init_log_files
  end

  def start_watch
    init_log_files
    @log_files.each do |lf|
      lf.start_watch unless lf.started
    end
    EM::Timer.new(5) do
      self.start_watch
    end
  end

  def init_log_files
    log_files = log_files_list(@dir)
    log_files.each do |filename|
      file_group = group_by_filename filename
      new_log_file = LogFile.new(filename, file_group, @procs)
      @log_files << new_log_file
      new_log_file.on_file_modification
    end
  end

  def log_files_list dir
    dirs = Dir[File.join(@dir, "**")].select{|d| File.directory? d}
    filenames = dirs.map do |d|
      Dir[File.join(d, "**", "*#{@options[:ext]}")].select{|f| File.file? f}
    end.flatten
    already_watched = @log_files.map(&:filename)
    filenames.reject{|fn| already_watched.include?(fn)}
  end

  def group_by_filename filename
    log_dir, log_filename = File.split(filename)
    log_filename = File.basename(log_filename, ".#{@options[:ext]}")
    group_values = File.join(log_dir, log_filename).split(File::SEPARATOR).last(@options[:group_sequence].length)

    file_group = {}
    @options[:group_sequence].each_with_index do |group_name, index|
      file_group[group_name] = group_values[index]
    end
    file_group
  end

  def logs_data time = nil
    @log_files.map{|lf| lf.file_data(time)}
  end

  def on_file_modification prok = nil, &block
    @procs[:file_modification] = if prok && prok.is_a?(Proc)
      prok
    elsif block_given?
      block
    end
  end
end
