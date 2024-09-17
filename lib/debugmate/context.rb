require 'debugmate/curl'

module Debugmate
    class Context
        attr_accessor :env, :extra_data

        def initialize(request, exception, extra_data = nil)
            @env = request if request.is_a? Hash
            @env = request.env if defined? (request.env)

            @exception = exception
            @extra_data = extra_data
        end

        def app
            controller = @env['action_dispatch.request.parameters']['controller'] if @env['action_dispatch.request.parameters'] && @env['action_dispatch.request.parameters']['controller']
            action = @env['action_dispatch.request.parameters']['action'] if @env['action_dispatch.request.parameters'] && @env['action_dispatch.request.parameters']['action']

            app = {
                controller: controller,
                route: {
                    name: action,
                    parameters: route_params
                },
                middlewares: {},
                view: {
                    name: nil,
                    data: nil
                }
            }

            app
        end

        def route_params
            clean_params = {}

            # based on https://github.com/rails/rails/blob/7-0-stable/actionpack/lib/action_dispatch/middleware/debug_view.rb
            params = @env['action_dispatch.request.parameters'] if @env['action_dispatch.request.parameters']

            clean_params = params.clone if params
            clean_params.delete("action")
            clean_params.delete("controller")
            clean_params
        end

        def request
            url = "#{@env['HTTP_HOST']}#{@env['PATH_INFO']}" if @env['HTTP_HOST'] && @env['PATH_INFO']
            method = "#{@env['REQUEST_METHOD']}" if @env['REQUEST_METHOD']
            url_params = @env['QUERY_STRING'] if @env['QUERY_STRING']

            # query string to hash: https://stackoverflow.com/a/16695721/2465086
            query_string = Hash[*url_params.split(/=|&/)] if url_params.is_a? String

            body = route_params if method == 'POST'

            curl = Curl.new(url_headers, route_params, url, method)

            request_info = {
                request: {
                    url: url,
                    method: method,
                    curl: curl.parsed
                },
                headers: url_headers,
                query_string: query_string ||= nil,
                body: body ||= nil,
                files: nil,
                session: session,
                cookies: {}
            }

            request_info
        end

        def url_headers
            headers = {}

            # Based on https://github.com/rails/rails/blob/7-0-stable/actionpack/lib/action_dispatch/middleware/show_exceptions.rb
            request = ActionDispatch::Request.new @env

            # Headers are extracted using splat operator. This is based on https://github.com/rails/rails/blob/7-0-stable/actionpack/lib/action_dispatch/middleware/templates/rescues/_request_and_response.html.erb
            headers = request.env.slice(*request.class::ENV_METHODS) if @env.is_a? Hash

            headers
        end

        def session
            session = {}

            request = ActionDispatch::Request.new @env

            session = request.session.to_h

            session
        end

        def environment
            environment = [
                {
                    group: 'Ruby on Rails',
                    variables: {
                        version: Rails.version,
                        locale: I18n.locale.to_s
                    }
                },
                {
                    group: 'App',
                    variables: {
                        environment: Rails.env,
                        date_time: Rails.configuration.time_zone
                    }
                },
                {
                    group: 'System',
                    variables: {
                        ruby: RUBY_VERSION,
                        os: RUBY_PLATFORM,
                        server_software: @env['SERVER_SOFTWARE'],
                        database_version: Rails.configuration.database_configuration[Rails.env]['adapter'],
                        browser_version: @env['HTTP_USER_AGENT']
                    }
                }
            ]

            environment
        end

        def user
            begin
              user_controller = @env['action_controller.instance'] if @env['action_controller.instance']
              user = user_controller.send(:current_user) if user_controller

              user
            rescue NoMethodError
                nil
            end
        end
    end
end
