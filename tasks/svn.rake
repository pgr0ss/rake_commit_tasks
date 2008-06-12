namespace :svn do
  task :st do
    puts %x[svn st]
  end

  task :up do
    status = %x[svn up]
    puts status
    status.each do |line|
      raise "SVN conflict detected. Please resolve conflicts before proceeding." if line =~ /^C\s+/
    end
  end

  task :add do
    %x[svn st].split(/\n/).each do |line|
      trimmed_line = line.delete('?').lstrip
      if new_file?(line) && !conflict?(line)
        %x[svn add #{trimmed_line}]
        puts %[added #{trimmed_line}]
      end
    end
  end
  
  def new_file?(line)
    line[0,1] =~ /\?/
  end
  
  def conflict?(line)
    line =~ /\.r\d+$/ || line =~ /\.mine$/
  end
  
  task :delete do
    %x[svn st].split(/\n/).each do |line|
      trimmed_line = line.delete('!').lstrip
      if line[0,1] =~ /\!/
        %x[svn up #{trimmed_line} && svn rm #{trimmed_line}]
        puts %[removed #{trimmed_line}]
      end
    end
  end
end
