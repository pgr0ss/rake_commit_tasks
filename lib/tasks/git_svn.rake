namespace :git_svn do

conflict_resolution = <<-EOS
'git svn rebase' failed! You probably have a conflict, to fix the conflict:
  fix the file
  git add [conflicted file]
  git rebase --continue"
EOS

  desc "rebase with the main svn repo"
  task :rebase do
    sh "git svn rebase"
    unless $?.success?
      raise conflict_resolution
    end
  end
  
  desc "dcommit to main svn repo"
  task :dcommit do
    sh "git svn dcommit"
  end
end
