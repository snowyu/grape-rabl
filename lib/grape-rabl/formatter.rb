module Grape
  module Middleware
    class Formatter
      alias :old_after :after

      def after
        status, headers, bodies = *@app_response
        current_endpoint = env['api.endpoint']


        status, headers, bodies = *@app_response
        current_endpoint = env['api.endpoint']

        rabl(current_endpoint) do |template|
          #engine = ::Tilt.new(view_path(template))
          #rendered = engine.render(current_endpoint, {})
          bodymap = bodies.collect do |body|
            #formatter.call(body)
            ::Rabl.render(body, template, :view_path => env['api.tilt.root'], :format => env['api.format'])
          end
          headers['Content-Type'] = content_types[env['api.format']]
          Rack::Response.new(bodymap, status, headers).to_a
        end
      end

      private

      def view_path(template)
        if template.split(".")[-1] == "rabl"
          File.join(env['api.tilt.root'], template)
        else
          File.join(env['api.tilt.root'], (template + ".rabl"))
        end
      end

      def rabl(endpoint)
        if template = rablable?(endpoint)
          yield template
        else
          old_after
        end
      end

      def rablable?(endpoint)
        if template = endpoint.options[:route_options][:rabl]
          set_view_root unless env['api.tilt.root']
          template
        else
          false
        end
      end

      def set_view_root
        raise "Use Rack::Config to set 'api.tilt.root' in config.ru"
      end
    end
  end
end
