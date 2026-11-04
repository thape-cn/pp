require "test_helper"
require "open3"

class SystemTestConfigurationTest < ActiveSupport::TestCase
  test "parallel browser workers inherit resolved Chrome and ChromeDriver paths" do
    # Keep the system-test hooks and Selenium globals out of the unit-test process.
    script = <<~RUBY
      require "application_system_test_case"

      parent_pid = Process.pid
      manager_calls = 0
      driver_path = RbConfig.ruby
      browser_path = "/bin/sh"
      Selenium::WebDriver::SeleniumManager.define_singleton_method(:binary_paths) do |*|
        raise "Selenium Manager ran in a worker" unless Process.pid == parent_pid

        manager_calls += 1
        {"driver_path" => driver_path, "browser_path" => browser_path}
      end

      ActiveSupport::Testing::Parallelization.before_fork_hooks.each(&:call)
      raise "Expected one Selenium Manager call" unless manager_calls == 1

      workers = 2.times.map do
        fork do
          %i[chrome headless_chrome].each do |name|
            driver = Capybara.drivers.fetch(name).call(nil)
            options = driver.options.fetch(:options)
            service = Selenium::WebDriver::Chrome::Service.new
            finder = Selenium::WebDriver::DriverFinder.new(options, service)
            raise "ChromeDriver path was not inherited" unless finder.driver_path == driver_path
            binary = options.as_json.fetch("goog:chromeOptions").fetch("binary")
            raise "Chrome path was not inherited" unless binary == browser_path
          end
          exit! 0
        end
      end

      statuses = workers.map { |pid| Process.wait2(pid).last }
      exit!(statuses.all?(&:success?) ? 0 : 1)
    RUBY

    output, errors, status = Open3.capture3(
      {"SE_CHROMEDRIVER" => nil}, RbConfig.ruby, "-Itest", "-e", script, chdir: Rails.root
    )

    assert status.success?, "#{output}\n#{errors}"
  end
end
