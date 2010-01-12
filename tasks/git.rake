def git_branch
  output = `git symbolic-ref HEAD`
  return nil unless $?.success?
  output.gsub('refs/heads/', '')
end

namespace :git do
  desc "display git status"
  task :st do
    sh "git status"
  end

  desc "add files to git index"
  task :add do
    sh "git add -A ."
  end

  desc "reset soft back to #{git_branch}"
  task :reset_soft do
    raise "Could not determine branch" unless git_branch
    sh "git reset --soft origin/#{git_branch}"
  end

  desc "pull from origin and rebase to keep a linear history"
  task :pull_rebase do
    sh "git pull --rebase"
  end

  desc "push to origin"
  task :push do
    sh "git push origin #{git_branch}"
  end
end
