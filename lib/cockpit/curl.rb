module Cockpit
    class Curl
        def initialize(headers, params, url, method)
            @headers = headers
            @params = params
            @url = url
            @method = method
        end

        def parsed
            headers_clean = @headers.clone
            headers_clean.delete("GATEWAY_INTERFACE")
            headers_clean.delete("REMOTE_ADDR")
            headers_clean.delete("SERVER_NAME")
            headers_clean.delete("SERVER_PROTOCOL")
            headers_clean.delete("ORIGINAL_SCRIPT_NAME")
            headers_clean.delete("HTTP_VERSION")

            headers_line = ""
            headers_clean.each do |header|
                value = header[1]
                value = value.downcase unless header[0].downcase.include? 'token'

                headers_line = headers_line + "-H '#{header[0].gsub(/HTTP_/, '').downcase}: #{value}' \\\n"
            end

            post_fields = ""
            @params.each do |param|
                if param[1].is_a? Hash
                    param[1].each do |label, val|
                        post_fields = post_fields + "-d '#{param[0]}[#{label}]=#{val}' \\\n"
                    end
                else
                    post_fields = post_fields + "-d '#{param[0]}=#{param[1]}' \\\n"
                end
            end

            curl = <<~CURL
            curl '#{@url}' \\
            -X #{@method} \\
            #{headers_line.chop}
            #{post_fields.chop}
            CURL
        end
    end
end
