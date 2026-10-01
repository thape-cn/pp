require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # removes noisy logs when launching tests
  Capybara.server = :puma, {Silent: true}

  Capybara.register_driver :headless_chrome do |app|
    options = Selenium::WebDriver::Chrome::Options.new(args: %w[headless window-size=1400,1000])
    options.logging_prefs = {browser: "ALL"}
    Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
  end

  Capybara.register_driver(:chrome) do |app|
    options = Selenium::WebDriver::Chrome::Options.new(args: %w[window-size=1400,1000])
    options.logging_prefs = {browser: "ALL"}
    Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
  end

  ENV["HEADLESS"] ? driven_by(:headless_chrome) : driven_by(:chrome)

  teardown do
    assert_no_browser_errors
  end

  def assert_no_browser_errors
    messages = page.driver.browser.logs.get(:browser).select do |entry|
      %w[WARNING SEVERE].include?(entry.level)
    end
    assert_empty messages, messages.map(&:message).join("\n")
  end
end
