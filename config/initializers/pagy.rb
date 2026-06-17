# frozen_string_literal: true

# Pagy initializer file (43.5.6)
# See https://ddnexus.github.io/pagy/toolbox/configuration/initializer/

Pagy::OPTIONS[:limit] = 10 # change is also needed in user.preferred_page_length default

Pagy::OPTIONS.freeze
