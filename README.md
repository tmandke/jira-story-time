jira-story-time
===============

Notes: 
- in `src/story.js` if you set `Story.devMode = false;` it will start updating story points.
- in `src/story.js` if you set `Story.autoUpdate = flase;` it will stop auto updating from server.

Development
===
- go to 'chrome://extensions/'
- scroll to the bottom and click on 'Keyboard shortcuts'
- set 'Extention Reloader' to 'Ctrl+Shift+R'

- clone this repository
- install ruby
- bundle install
- bundle exec guard
- in the bundle console run `all` (needs to be done first time to create all files)
- go to Jira agile board and start developing
