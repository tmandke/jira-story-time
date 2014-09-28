
require 'crxmake'

task :package do
  sha = `git log --pretty=format:'%h' -n 1`
  
  CrxMake.make(
    :ex_dir => "./extension",
    :crx_output => "./jira-story-time-#{sha}.crx",
    :verbose => true
  )  
end