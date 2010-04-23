namespace :git do
  desc "display git status"
  task :st do
    sh "git status"
  end

  desc "add files to git index"
  task :add do
    sh "git add -A ."
  end

  desc "reset soft back to common ancestor of branch and origin/branch"
  task :reset_soft do
    raise "Could not determine branch" unless git_branch
    sh "git reset --soft #{merge_base}"
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

def git_branch
  output = `git symbolic-ref HEAD`
  return nil unless $?.success?
  output.gsub('refs/heads/', '').strip
end

def merge_commits?
  `git log --merges #{merge_base}..HEAD`.any?
end

def merge_base
  `git merge-base #{git_branch} origin/#{git_branch}`.strip
end
