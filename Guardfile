#!/usr/bin/env ruby
require 'json'
RELOAD_SCRIPT = <<SCRIPT
tell application "Google Chrome" to tell the active tab of its first window
  activate
  tell application "System Events" to keystroke "r" using { control down, shift down }
  reload
end tell
SCRIPT

manifest = {
  name:             "Jira Story time",
  version:          "0.0.1",
  manifest_version: 2,
  description:      "this adds overlay to ",
  homepage_url:     "http://extensionizr.com",
  default_locale:   "en",
  permissions: [ "https://*/*" ],
  icons: {
    16 =>   "icons/icon16.png",
    48 =>   "icons/icon48.png",
    128 =>  "icons/icon128.png"
  },
  content_scripts: [
    {
      run_at:   "document_end",
      html:     [ "templates/*.html", "templates/*.css" ],
      matches:  [ "https://*/secure/RapidBoard.jspa*" ],
      js: ["js/templates.js"]
    }
  ],
  web_accessible_resources: [ "templates/*.html", "templates/*.css" ]
}

guard 'shell' do
  watch(%r{^extension/.+\.js}) do |m|
    manifest[:content_scripts][0][:js] += Dir["extension/js/*.js"].map{|f| f.gsub('extension/', '')}
    manifest[:content_scripts][0][:js].uniq!
    File.open('extension/manifest.json', 'w') { |file| file.write(manifest.to_json) }
  end
  watch(%r{^extension/.+\.(html|js|css|png|gif|jpg)}) do |m|
    system "osascript -e '#{RELOAD_SCRIPT}'"
  end
end

guard 'shell' do
  watch( %r{src/(.+).slim} ) { |m| `slimrb -p #{m[0]} extension/#{m[1]}.html` }
end

guard 'sass', input: 'src/sass', output: 'extension/templates'

guard 'coffeescript', input: 'src/coffee', output: 'extension/js', bare: true
