require "test_helper"
require "open3"

class BabelConfigTest < ActiveSupport::TestCase
  %w[development test production].each do |environment|
    test "JSX renders without a React import in #{environment}" do
      script = <<~JS
        const babel = require("@babel/core");
        const vm = require("node:vm");
        const { renderToStaticMarkup } = require("react-dom/server");
        const { code } = babel.transformSync(
          'module.exports = <button type="button">Save</button>;',
          { filename: "app/javascript/react/Example.jsx" }
        );
        const context = { module: { exports: {} }, require };
        vm.runInNewContext(code, context);
        process.stdout.write(renderToStaticMarkup(context.module.exports));
      JS

      output, errors, status = Open3.capture3(
        {"NODE_ENV" => environment, "BABEL_ENV" => environment},
        "node", "-e", script, chdir: Rails.root
      )

      assert status.success?, errors
      assert_equal '<button type="button">Save</button>', output
      assert_empty errors
    end
  end
end
