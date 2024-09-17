module Debugmate
    class Trace
        def initialize(exception, request = {})
            @exception = exception
            @env = request
            @env = request.env if defined? (request.env)
        end

        def parsed

            wrapped = ActionDispatch::ExceptionWrapper.new(ActiveSupport::BacktraceCleaner.new, @exception)
        
            function = @env['action_dispatch.request.parameters']['action'] if @env['action_dispatch.request.parameters'] && @env['action_dispatch.request.parameters']['action']

            trace = [
                {
                    file: @exception.backtrace[wrapped.source_to_show_id],
                    line: wrapped.source_extracts[wrapped.source_to_show_id][:line_number] ||= nil,
                    function: function,
                    class: @exception.backtrace[wrapped.source_to_show_id] ||= nil,
                    preview: wrapped.source_extracts[wrapped.source_to_show_id][:code] ||= nil
                }
            ]
        end
    end
end
