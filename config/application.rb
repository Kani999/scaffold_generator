require_relative 'boot'

require 'csv'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Sccs
  # Configure sccs
  class Application < Rails::Application

    # resource_controller defines which generator to use for generating a controller when using rails generate resource. Defaults to :controller.

    # scaffold_controller different from resource_controller, defines which generator to use for generating a scaffolded controller when using rails generate scaffold. Defaults to :scaffold_controller.

    # stylesheets turns on the hook for stylesheets in generators. Used in Rails for when the scaffold generator is ran, but this hook can be used in other generates as well. Defaults to true.

    # stylesheet_engine configures the stylesheet engine (for eg. sass) to be used when generating assets. Defaults to :css.

    # test_framework defines which test framework to use. Defaults to false and will use Test::Unit by default.

    # template_engine defines which template engine to use, such as ERB or Haml. Defaults to :erb.

    config.generators do |gen|
      gen.orm :active_record
      gen.template_engine :haml
      gen.test_framework :rspec,
                         fixtures: true,
                         view_specs: true,
                         helper_specs: true,
                         routing_specs: true,
                         controller_specs: true,
                         request_specs: true
      gen.helper :helper_and_policy
      gen.scaffold_controller :controller_with_smart_listing
      gen.fixture_replacement :factory_bot, dir: "spec/factories"
    end
  end
end

