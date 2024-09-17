require 'debugmate/publish'

module Debugmate
    class Handler

        def initialize(env, exception)
            @env = env
            @exception = exception
        end

        def capture

            query_data = {
                query: Debugmate::ExceptionHandler.last_executed_query.tr('"',"'"),
                binds: Debugmate::ExceptionHandler.last_executed_binds
            }

            publish = Publish.new(@exception, @env, query_data).execute

            Debugmate::ExceptionHandler.last_executed_query = ''
            Debugmate::ExceptionHandler.last_executed_binds = {}

            publish
        end
    end
end
