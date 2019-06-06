require 'rails/generators/rails/scaffold_controller/scaffold_controller_generator'

module Rails
  module Generators
    # Controller With Smart Listing Generator
    class ControllerWithSmartListingGenerator < ScaffoldControllerGenerator
      source_root File.expand_path('templates', __dir__)
      check_class_collision suffix: "Controller"
      argument :actions, type: :array, default: [], banner: "action action"
      class_option :skip_routes, type: :boolean, desc: "Don't add routes to config/routes.rb."

      def create_controller_files
        template 'controller.rb', File.join('app/controllers', class_path, "#{controller_file_name}_controller.rb")
      end

      def add_routes
        return unless options[:skip_routes]

        actions.reverse_each do |action|
          # route prepends two spaces onto the front of the string that is passed, this corrects that.
          route generate_routing_code(action)[2..-1]
        end
      end

      private

      # Create 'namespace' ladder
      # namespace :foo do
      #   namespace :bar do
      def get_namespace_ladder(regular_class_path)
        regular_class_path.each_with_index.map do |ns, index|
          indent("  namespace :#{ns} do\n", index * 2)
        end.join
      end

      # Create `end` ladder
      #   end
      # end
      def get_end_ladder(depth)
        (1..depth).reverse_each.map do |index|
          indent("end\n", index * 2)
        end.join
      end

      # This method creates nested route entry for namespaced resources.
      # For eg. rails g controller foo/bar/baz index
      # Will generate -
      # namespace :foo do
      #   namespace :bar do
      #     get 'baz/index'
      #   end
      # end
      def generate_routing_code(action)
        depth = regular_class_path.length
        namespace_ladder = get_namespace_ladder(regular_class_path)

        # Create route
        #     get 'baz/index'
        route = indent(%(  get '#{file_name}/#{action}'\n), depth * 2)

        end_ladder = get_end_ladder(depth)

        # Combine the 3 parts to generate complete route entry
        namespace_ladder + route + end_ladder
      end

      protected

      def handler
        :haml
      end

      hook_for :form_builder, as: :scaffold
      hook_for :jbuilder, default: true
    end
  end
end

