require 'net/http'
require 'debugmate/context'
require 'debugmate/trace'

module Debugmate
    class Publish
        def initialize(exception, request = {}, extra_data = nil)
            @exception = exception
            @request = request
            @extra_data = extra_data
        end

        def execute
            uri = URI("#{DEBUGMATE_CONFIG['data']['domain']}/api/capture")
      
            headers = {
                'X-DEBUGMATE-TOKEN' => DEBUGMATE_CONFIG['data']['token'],
                'Content-Type' => 'application/json',
                'Accept' => 'application/json'
            }

            result = Net::HTTP.post(uri, payload.to_json, headers)

            result
        end

        def payload
            context = Context.new(@request, @exception, @extra_data)

            trace = Trace.new(@exception, @request)
            
            data = {
                exception: @exception.class.to_s,
                message: @exception.message,
                file: trace.parsed[0][:file],
                type: 'web',
                trace: trace.parsed,
                app: context.app,
                request: context.request,
                environment: context.environment,
                user: context.user || [],
                context: context.extra_data || []
            }

            data
        end
    end
end
