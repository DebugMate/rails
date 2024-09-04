require 'cockpit/publish'

module Cockpit
    class Handler

        def initialize(env, exception)
            @env = env
            @exception = exception
        end

        def capture

            query_data = {
                query: Cockpit::ExceptionHandler.last_executed_query.tr('"',"'"),
                binds: Cockpit::ExceptionHandler.last_executed_binds
            }

            publish = Publish.new(@exception, @env, query_data).execute

            Cockpit::ExceptionHandler.last_executed_query = ''
            Cockpit::ExceptionHandler.last_executed_binds = {}

            publish
          end
    end
end
