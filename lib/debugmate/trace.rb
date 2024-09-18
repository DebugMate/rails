module Debugmate
    class Trace
      def initialize(exception, request = {})
        @exception = exception
        @env = request.is_a?(Hash) ? request : (request.env if request.respond_to?(:env))
      end
  
      def parsed
        wrapped = ActionDispatch::ExceptionWrapper.new(ActiveSupport::BacktraceCleaner.new, @exception)
      
        function = @env.dig('action_dispatch.request.parameters', 'action')
  
        source_to_show_id = wrapped.source_to_show_id
        backtrace = @exception.backtrace
  
        trace = if source_to_show_id && backtrace
          [{
            file: backtrace[source_to_show_id].to_s,
            line: wrapped.source_extracts.dig(source_to_show_id, :line_number),
            function: function,
            class: extract_class(backtrace[source_to_show_id]),
            preview: wrapped.source_extracts.dig(source_to_show_id, :code)
          }]
        else
          [{
            file: backtrace&.first.to_s,
            line: nil,
            function: function,
            class: extract_class(backtrace&.first),
            preview: nil
          }]
        end
  
        trace
      end
  
      private
  
      def extract_class(backtrace_line)
        return "Unknown" if backtrace_line.nil?
        
        # Tenta extrair o nome da classe do backtrace
        match = backtrace_line.match(/^(.+?):(\d+):in/)
        if match
          file_path = match[1]
          class_name = File.basename(file_path, ".*").split("_").map(&:capitalize).join
          class_name.empty? ? "Unknown" : class_name
        else
          "Unknown"
        end
      end
    end
end
  