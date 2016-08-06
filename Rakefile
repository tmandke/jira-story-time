require 'crxmake'

task :package do
  sha = `git log --pretty=format:'%h' -n 1`

  CrxMake.make(
    :ex_dir => "./extension",
    :crx_output => "./jira-story-time-#{sha}.crx",
    :verbose => true
  )
end

require 'jasmine'
require 'jasmine_selenium_runner'
require 'guard'
task :guard_all do
  Guard.run_all()
end

task :coffeelint do
  exit system "coffeelint -f CoffeeLint.json #{Dir["**/*.coffee"].join(" ")}"
end

module Jasmine
  module Runners
    class Selenium
      def run
        driver.navigate.to jasmine_server_url
        ensure_connection_established
        wait_for_suites_to_finish_running

        spec_results = get_results
        formatter.format(spec_results)
        formatter.format(get_blanket_results(spec_results.length))
        formatter.done
      ensure
        driver.quit
      end
      def get_blanket_results length
        results = driver.execute_script(<<-JS)
          return window.blanketResults;
        JS

        expectations = results['files'].map{|f,d| __createBlanketExpectation(f, d) }
        expectations << __createBlanketExpectation("Global Total", results)
        jasmineResult = {
          'description' => "should be 100%",
          'failedExpectations' => expectations.select{|e| !e['passed']},
          'fullName' => "Coverage should be 100%",
          'id' => "spec#{length}",
          'passedExpectations' => expectations.select{|e| e['passed']}
        }
        jasmineResult['status'] = jasmineResult['failedExpectations'].empty? ? "passed" : "failed"
        Jasmine::Result.map_raw_results([jasmineResult])
      end
      def __createBlanketExpectation file, data
        percentage = (data['passedBranches'] + data['numberOfFilesCovered']) * 1.0 / (data['totalBranches'] + data['totalSmts'])
        {
          'actual' => percentage,
          'expected' => 100,
          'matcherName' => "not.toBeLessThan",
          'message' => "#{file} #{data['passedBranches']}/#{data['totalBranches']} #{data['numberOfFilesCovered']}/#{data['totalSmts']} = #{percentage * 100}%",
          'passed' => percentage >= 1.0,
          'stack' => ""
        }
      end
    end
  end
end

load 'jasmine/tasks/jasmine.rake'
