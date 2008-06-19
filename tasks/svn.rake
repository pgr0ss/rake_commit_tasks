namespace :svn do
  desc "display svn status"
  task :st do
    puts %x[svn st]
  end

  desc "svn up and check for conflicts"
  task :up do
    output = %x[svn up]
    puts output
    output.each do |line|
      raise "SVN conflict detected. Please resolve conflicts before proceeding." if line[0,1] == "C"
    end
  end

  desc "add new files to svn"
  task :add do
    %x[svn st].split("\n").each do |line|
      if new_file?(line) && !svn_conflict_file?(line)
        file = line[7..-1]
        %x[svn add #{file.inspect}]
        puts %[added #{file}]
      end
    end
  end
  
  def new_file?(line)
    line[0,1] == "?"
  end
  
  def svn_conflict_file?(line)
    line =~ /\.r\d+$/ || line =~ /\.mine$/
  end
  
  desc "remove deleted files from svn"
  task :delete do
    %x[svn st].split("\n").each do |line|
      if line[0,1] == "!"
        file = line[7..-1]
        %x[svn up #{file.inspect} && svn rm #{file.inspect}]
        puts %[removed #{file}]
      end
    end
  end
  task :rm => "svn:delete"
  
  desc "reverts all files in svn and deletes new files"
  task :revert_all do
    system "svn revert -R ."
    %x[svn st].split("\n").each do |line|
      next unless line[0,1] == '?'
      filename = line[1..-1].strip
      puts "removed #{filename}"
      rm_r filename
    end
  end

end
