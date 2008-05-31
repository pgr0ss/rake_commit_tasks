desc "Run before checking in"
task :pc => ['svn:add', 'svn:delete', 'svn:up', :default, 'svn:st']

desc "Run to check in"
task :commit => :pc do
  commit_pair = retrieve_saved_data "pair"
  commit_message = retrieve_saved_data "message"
  command = %[svn ci -m "#{commit_pair.chomp} - #{commit_message.chomp}"]
  puts command
  puts %x[#{command}]
end

def retrieve_saved_data attribute
  data_path = File.expand_path(File.dirname(__FILE__) + "/#{attribute}.data")
  `touch #{data_path}` unless File.exist? data_path
  saved_data = File.read(data_path)
  
  puts "last #{attribute}: " + saved_data unless saved_data.chomp.empty?
  print "#{attribute}: "

  input = STDIN.gets
  while (saved_data.chomp.empty? && (input.chomp.empty?))
    print "#{attribute}: "
    input = STDIN.gets
  end
  if input.chomp.any?
    File.open(data_path, "w") { |file| file << input }
  else
    puts "using: " + saved_data.chomp
  end
  input.chomp.any? ? input : saved_data
end
