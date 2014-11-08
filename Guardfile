#!/usr/bin/env ruby
require 'json'
require 'fileutils'
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
      matches:  [ "https://*/secure/RapidBoard.jspa*", "http://*/secure/RapidBoard.jspa*" ],
      js: %w(js/jquery.min.js js/init.js)
    }
  ],
  web_accessible_resources: [ "templates/*.html", "templates/*.css" ]
}

class Reloader
  attr_accessor :should_reload
  def initialize
    @should_reload = false
    @thread = Thread.new(self) { |reloader|
      loop do
        sleep 5
        reloader.reload! if reloader.should_reload
      end
    }
  end
  
  def reload
    @should_reload = true
  end
  
  def reload!
    system "osascript -e '#{RELOAD_SCRIPT}'"  unless Env['DISABLE_RELOADER'] == 'true'
    @should_reload = false
  end
end

RELOADER ||= Reloader.new


guard 'shell' do
  watch(%r{^extension/.+\.js}) do |m|
    jsList = manifest[:content_scripts][0][:js]
    manifest[:content_scripts][0][:js] += Dir['extension/js/utils/*.js'].map{|f| f.gsub('extension/', '')}
    manifest[:content_scripts][0][:js] += Dir['extension/js/models/*.js'].map{|f| f.gsub('extension/', '')}
    manifest[:content_scripts][0][:js] += Dir['extension/js/**/*.js'].map{|f| f.gsub('extension/', '')}
    manifest[:content_scripts][0][:js].uniq!
    File.open('extension/manifest.json', 'w') { |file| file.write(manifest.to_json) }
    manifest[:content_scripts][0][:js] = jsList
  end
  
  watch(%r{^extension/.+\.(html|js|css|png|gif|jpg)}) do |m|
    RELOADER.reload
  end
end

guard 'shell' do
  watch( %r{src/(.+).slim} ) { |m| `slimrb -p #{m[0]} extension/#{m[1]}.html` }
end

guard 'sass', input: 'src/sass', output: 'extension/templates'

guard 'coffeescript', input: 'src/coffee', output: 'extension/js', bare: true
group :spec do
  guard 'shell' do
    watch( %r{spec/coffee/fixtures/(.+).slim} ) { |m| `slimrb -p #{m[0]} spec/javascripts/fixtures/#{m[1]}.html` }
    watch( %r{spec/coffee/fixtures/json/(.+).json} ) { |m|
      file_name = "spec/javascripts/fixtures/json/#{m[1]}.json"
      FileUtils.mkdir_p(File.dirname file_name)
      `cp -p #{m[0]} #{file_name}`
    }
  end

  guard 'coffeescript', input: 'spec/coffee', output: 'spec/javascripts', bare: true
end

