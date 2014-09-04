#!/usr/bin/env ruby
require 'json'
RELOAD_SCRIPT = <<SCRIPT
tell application "Google Chrome" to tell the active tab of its first window
  activate
  tell application "System Events" to keystroke "r" using { control down, shift down }
  reload
end tell
SCRIPT

puts "be sure to configure chrome to reload on ctl-shift-r"
manifest = {
  name:             "Jira Story time",
  version:          "0.0.1",
  manifest_version: 2,
  description:      "this adds overlay to ",
  homepage_url:     "http://extensionizr.com",
  default_locale:   "en",
  permissions: [ "https://*/*" ],
  icons: {
    16 =>   "src/icons/icon16.png",
    48 =>   "src/icons/icon48.png",
    128 =>  "src/icons/icon128.png"
  },
  content_scripts: [
    {
      run_at:   "document_end",
      html:     [ "src/templates/*.html" ],
      matches:  [ "https://jira2.workday.com/secure/RapidBoard.jspa*" ],
      js: ["src/js/templates.js"]
    }
  ],
  web_accessible_resources: [ "src/templates/*.html" ]
}

while true do
  puts "space to reload, q to quit"
  begin
    system("stty raw -echo")
    str = STDIN.getc
  ensure
    system("stty -raw echo")
  end
  
  case str
  when ' ', '\n' 
    system "clear"
    puts "reloading"
    system "coffee --output src/js/ --compile src/coffee/"

    manifest[:content_scripts][0][:js] << Dir["src/js/*.js"]
    manifest[:content_scripts][0][:js].flatten!.uniq!

    File.open('manifest.json', 'w') { |file| file.write(manifest.to_json) }

    system "osascript -e '#{RELOAD_SCRIPT}'"
  when 'q'
    break
  end
end