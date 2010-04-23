namespace :git_svn do

  desc "rebase with the main svn repo"
  task :rebase do
    sh "git svn rebase"
  end

  desc "dcommit to main svn repo"
  task :dcommit do
    sh "git svn dcommit"
  end
end
