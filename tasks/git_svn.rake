
namespace :git_svn do

  desc "rebase with the main svn repo"
  task :rebase do
    sh "git svn rebase"
  end
  
  desc "dcommit to main svn repo"
  task :rebase do
    sh "git svn dcommit"
  end
  task :check_clean do
    sh "git status | grep -F 'nothing to commit (working directory clean)'"
    raise "Your working directory is not clean, either remove the modifications or git stash your changes and restore later" unless $?.success?
  end
end
