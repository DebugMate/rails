require 'rails_helper'
require 'cockpit/context'
require 'cockpit/publish'

describe Cockpit do
    context 'Context' do
        context 'App' do
            it 'has controller' do
                env = {
                    'action_dispatch.request.parameters' => {
                        'controller' => 'envtest'
                    }
                }

               context = Cockpit::Context.new(env, Cockpit::TestException.new)

               expect(context.app[:controller]).to eql("envtest")
            end

            it 'has route name' do
                env = {
                    'action_dispatch.request.parameters' => {
                        'action' => 'some_method'
                    }
                }

               context = Cockpit::Context.new(env, Cockpit::TestException.new)

               expect(context.app[:route][:name]).to eql("some_method")
            end

            it 'has route parameters' do
                env = {
                    "action_dispatch.request.parameters" => {
                        "_method"=>"patch", 
                        "authenticity_token"=>"TyhpLkYUpbbR5U9DFYIihuSMvUpVMXyYhqrPNtD6tHEKaSn9C_qye3kgBm2AL2LPh37zGcu0d0qCX0zE-6k6JA", 
                        "article"=>{
                            "title"=>"hello article - edit", 
                            "body"=>"this is a test - edit"
                        }, 
                        "commit"=>"Update Article", 
                        "controller"=>"articles", 
                        "action"=>"update", 
                        "id"=>"2"
                    }
                }

                context = Cockpit::Context.new(env, Cockpit::TestException.new)

                expect(context.app[:route][:parameters]).to eql({
                    "_method"=>"patch", 
                    "authenticity_token"=>"TyhpLkYUpbbR5U9DFYIihuSMvUpVMXyYhqrPNtD6tHEKaSn9C_qye3kgBm2AL2LPh37zGcu0d0qCX0zE-6k6JA", 
                    "article"=>{
                        "title"=>"hello article - edit", 
                        "body"=>"this is a test - edit"
                    }, 
                    "commit"=>"Update Article", 
                    "id"=>"2"
                })
            end
        end

        context 'Request' do
            it 'has request url' do
                env = {
                    'HTTP_HOST' => 'http://testing.com/',
                    'PATH_INFO' => 'some-path'
                }

                context = Cockpit::Context.new(env, Cockpit::TestException.new)

                expect(context.request[:request][:url]).to eql("http://testing.com/some-path")
            end

            it 'has request method' do
                env = {
                    'REQUEST_METHOD' => 'POST'
                }

                context = Cockpit::Context.new(env, Cockpit::TestException.new)

                expect(context.request[:request][:method]).to eql("POST")
            end

            it 'has request curl parsed' do
                parsed = <<~CURL
                curl 'http://testing.com/some-path' \\
                -X POST \\
                -H 'accept: text/vnd.turbo-stream.html, text/html, application/xhtml+xml' \\
                -H 'accept_encoding: gzip, deflate, br' \\
                -H 'accept_language: en-us,en;q=0.9' \\
                -H 'origin: http://localhost:3000' \\
                -H 'x_csrf_token: 5Wuec5MO2CgkS7GRNrCqygjkJh-x3Z71FHp78DZ_k573deCiz9B8VB6-3KSaq0Jzj7-JDarVF-NJ0x3PRe5anw' \\
                -d '_method=patch' \\
                -d 'authenticity_token=TyhpLkYUpbbR5U9DFYIihuSMvUpVMXyYhqrPNtD6tHEKaSn9C_qye3kgBm2AL2LPh37zGcu0d0qCX0zE-6k6JA' \\
                -d 'article[title]=hello article - edit' \\
                -d 'article[body]=this is a test - edit' \\
                -d 'commit=Update Article' \\
                -d 'id=2' \\
                CURL

                env = {
                    'HTTP_HOST' => 'http://testing.com/',
                    'PATH_INFO' => 'some-path',
                    'REQUEST_METHOD' => 'POST',
                    "action_dispatch.request.parameters" => {
                        "_method"=>"patch", 
                        "authenticity_token"=>"TyhpLkYUpbbR5U9DFYIihuSMvUpVMXyYhqrPNtD6tHEKaSn9C_qye3kgBm2AL2LPh37zGcu0d0qCX0zE-6k6JA", 
                        "article"=>{
                            "title"=>"hello article - edit", 
                            "body"=>"this is a test - edit"
                        }, 
                        "commit"=>"Update Article", 
                        "controller"=>"articles", 
                        "action"=>"update", 
                        "id"=>"2"
                    },
                    "rack.version"=>[1, 2],
                    "rack.input"=>'#<StringIO:0x000000060974b8>',
                    "rack.errors"=>'#<IO:<STDERR>>',
                    "rack.multithread"=>false,
                    "rack.multiprocess"=>false,
                    "rack.run_once"=>false,
                    "rack.url_scheme"=>"http",
                    "GATEWAY_INTERFACE"=>"CGI/1.2", 
                    "REMOTE_ADDR"=>"::1", 
                    "SERVER_NAME"=>"localhost", 
                    "SERVER_PROTOCOL"=>"HTTP/1.1", 
                    "ORIGINAL_SCRIPT_NAME"=>"", 
                    "HTTP_ACCEPT"=>"text/vnd.turbo-stream.html, text/html, application/xhtml+xml", 
                    "HTTP_ACCEPT_ENCODING"=>"gzip, deflate, br", 
                    "HTTP_ACCEPT_LANGUAGE"=>"en-US,en;q=0.9", 
                    "HTTP_ORIGIN"=>"http://localhost:3000", 
                    "HTTP_VERSION"=>"HTTP/1.1", 
                    "HTTP_X_CSRF_TOKEN"=>"5Wuec5MO2CgkS7GRNrCqygjkJh-x3Z71FHp78DZ_k573deCiz9B8VB6-3KSaq0Jzj7-JDarVF-NJ0x3PRe5anw"
                }

                context = Cockpit::Context.new(env, Cockpit::TestException.new)

                expect(context.request[:request][:curl]).to eql(parsed)
            end

            it 'has headers' do
                env = {
                    "rack.version"=>[1, 2],
                    "rack.input"=>'#<StringIO:0x000000060974b8>',
                    "rack.errors"=>'#<IO:<STDERR>>',
                    "rack.multithread"=>false,
                    "rack.multiprocess"=>false,
                    "rack.run_once"=>false,
                    "rack.url_scheme"=>"http",
                    "GATEWAY_INTERFACE"=>"CGI/1.2", 
                    "REMOTE_ADDR"=>"::1", 
                    "SERVER_NAME"=>"localhost", 
                    "SERVER_PROTOCOL"=>"HTTP/1.1", 
                    "ORIGINAL_SCRIPT_NAME"=>"", 
                    "HTTP_ACCEPT"=>"text/vnd.turbo-stream.html, text/html, application/xhtml+xml", 
                    "HTTP_ACCEPT_ENCODING"=>"gzip, deflate, br", 
                    "HTTP_ACCEPT_LANGUAGE"=>"en-US,en;q=0.9", 
                    "HTTP_ORIGIN"=>"http://localhost:3000", 
                    "HTTP_VERSION"=>"HTTP/1.1", 
                    "HTTP_X_CSRF_TOKEN"=>"5Wuec5MO2CgkS7GRNrCqygjkJh-x3Z71FHp78DZ_k573deCiz9B8VB6-3KSaq0Jzj7-JDarVF-NJ0x3PRe5anw"
                }

                expected = {
                    "GATEWAY_INTERFACE"=>"CGI/1.2", 
                    "REMOTE_ADDR"=>"::1", 
                    "SERVER_NAME"=>"localhost", 
                    "SERVER_PROTOCOL"=>"HTTP/1.1", 
                    "ORIGINAL_SCRIPT_NAME"=>"", 
                    "HTTP_ACCEPT"=>"text/vnd.turbo-stream.html, text/html, application/xhtml+xml", 
                    "HTTP_ACCEPT_ENCODING"=>"gzip, deflate, br", 
                    "HTTP_ACCEPT_LANGUAGE"=>"en-US,en;q=0.9", 
                    "HTTP_ORIGIN"=>"http://localhost:3000", 
                    "HTTP_VERSION"=>"HTTP/1.1", 
                    "HTTP_X_CSRF_TOKEN"=>"5Wuec5MO2CgkS7GRNrCqygjkJh-x3Z71FHp78DZ_k573deCiz9B8VB6-3KSaq0Jzj7-JDarVF-NJ0x3PRe5anw"
                }

                context = Cockpit::Context.new(env, Cockpit::TestException.new)

                expect(context.request[:headers]).to eql(expected)
            end

            it 'has query string if it is a string' do
                env = {
                    'QUERY_STRING' => 'some=test',
                }

                context = Cockpit::Context.new(env, Cockpit::TestException.new)

                expect(context.request[:query_string]).to eql({'some' => 'test'})
            end

            it 'does not have query string if it is not a string' do
                env = {
                    'QUERY_STRING' => nil,
                }

                context = Cockpit::Context.new(env, Cockpit::TestException.new)

                expect(context.request[:query_string]).to be_nil
            end

            it 'has body if method is POST' do
                env = {
                    'REQUEST_METHOD' => 'POST',
                    "action_dispatch.request.parameters" => {
                        "_method"=>"patch", 
                        "authenticity_token"=>"TyhpLkYUpbbR5U9DFYIihuSMvUpVMXyYhqrPNtD6tHEKaSn9C_qye3kgBm2AL2LPh37zGcu0d0qCX0zE-6k6JA", 
                        "article"=>{
                            "title"=>"hello article - edit", 
                            "body"=>"this is a test - edit"
                        }, 
                        "commit"=>"Update Article", 
                        "controller"=>"articles", 
                        "action"=>"update", 
                        "id"=>"2"
                    }
                }

                context = Cockpit::Context.new(env, Cockpit::TestException.new)

                expect(context.request[:body]).to eql({
                    "_method"=>"patch", 
                    "authenticity_token"=>"TyhpLkYUpbbR5U9DFYIihuSMvUpVMXyYhqrPNtD6tHEKaSn9C_qye3kgBm2AL2LPh37zGcu0d0qCX0zE-6k6JA", 
                    "article"=>{
                        "title"=>"hello article - edit", 
                        "body"=>"this is a test - edit"
                    }, 
                    "commit"=>"Update Article", 
                    "id"=>"2"
                })
            end

            it 'does not have body if method is different from POST' do
                env = {
                    'REQUEST_METHOD' => 'GET',
                    "action_dispatch.request.parameters" => {
                        "_method"=>"patch", 
                        "authenticity_token"=>"TyhpLkYUpbbR5U9DFYIihuSMvUpVMXyYhqrPNtD6tHEKaSn9C_qye3kgBm2AL2LPh37zGcu0d0qCX0zE-6k6JA", 
                        "article"=>{
                            "title"=>"hello article - edit", 
                            "body"=>"this is a test - edit"
                        }, 
                        "commit"=>"Update Article", 
                        "controller"=>"articles", 
                        "action"=>"update", 
                        "id"=>"2"
                    }
                }

                context = Cockpit::Context.new(env, Cockpit::TestException.new)

                expect(context.request[:body]).to be_nil
            end

            it 'has session' do
                env = {
                    'rack.session' => {
                        "session_id"=>"a3f06e23af130375fff96d249fc65113", 
                        "_csrf_token"=>"r28uAY4753fZuMG3GQADNT8B_sHBqppL9ZXJt8DR5o4"
                    }
                }

                context = Cockpit::Context.new(env, Cockpit::TestException.new)

                expect(context.request[:session]).to eql({
                    "session_id"=>"a3f06e23af130375fff96d249fc65113", 
                    "_csrf_token"=>"r28uAY4753fZuMG3GQADNT8B_sHBqppL9ZXJt8DR5o4"
                })
            end
        end

        context 'Environment' do
            it 'contains correct data' do
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
                        server_software: 'Some server',
                        database_version: Rails.configuration.database_configuration[Rails.env]['adapter'],
                        browser_version: 'Some agent'
                    }
                }
            ]

            env = {
                'SERVER_SOFTWARE' => 'Some server',
                'HTTP_USER_AGENT' => 'Some agent'
            }

            context = Cockpit::Context.new(env, Cockpit::TestException.new)

            expect(context.environment).to eql(environment)
            end
        end

        context 'User' do

            it 'sets user from controller if method current_user exists' do
                user = {
                    id: 88,
                    name: "Rails user from double",
                    email: "rail_doubles@user.com"
                }

                controller = double(ApplicationController, :current_user => user)

                env = {'action_controller.instance' => controller}

                context = Cockpit::Context.new(env, Cockpit::TestException.new)

                expect(context.user).to eql(user)
            end

            it 'sets user to nil if method current_user does not exists' do
                context = Cockpit::Context.new({}, Cockpit::TestException.new)

                expect(context.user).to be_nil
            end
        end
    end

    context 'Publish' do
        context 'payload' do
            it 'sends only with exception' do
                exception = Cockpit::TestException.new
                exception.set_backtrace(caller)

                publish = Cockpit::Publish.new(exception)

                expect(publish.payload[:exception]).to eql('Cockpit::TestException')
                expect(publish.payload[:message]).to eql('Test generated by the cockpit:test rails command')
                expect(publish.payload[:file]).to include('rspec')
                expect(publish.payload[:type]).to eql('web')
                expect(publish.payload[:trace]).to be_an(Array)
                expect(publish.payload[:trace][0]).to be_a(Hash)
                expect(publish.payload[:trace][0][:file]).to be_a(String)
                expect(publish.payload[:trace][0][:line]).to be_an(Integer)
                expect(publish.payload[:trace][0][:function]).to be_nil
                expect(publish.payload[:trace][0][:class]).to be_a(String)
                expect(publish.payload[:trace][0][:preview]).to be_a(Hash)
                expect(publish.payload[:trace][0][:preview].count).to eql(6)
            end

            it 'sends with exception and request' do
                exception = Cockpit::TestException.new
                exception.set_backtrace(caller)

                request = {
                    'action_dispatch.request.parameters' => {
                        'controller' => 'envtest'
                    }
                }

                publish = Cockpit::Publish.new(exception, request)

                expect(publish.payload[:exception]).to eql('Cockpit::TestException')
                expect(publish.payload[:app][:controller]).to eql("envtest")
            end

            it 'sends with exception, request and extra_data' do
                exception = Cockpit::TestException.new
                exception.set_backtrace(caller)

                request = {
                    'action_dispatch.request.parameters' => {
                        'controller' => 'envtest'
                    }
                }

                extra = {some: 'extra info'}

                publish = Cockpit::Publish.new(exception, request, extra)

                expect(publish.payload[:exception]).to eql('Cockpit::TestException')
                expect(publish.payload[:app][:controller]).to eql("envtest")
                expect(publish.payload[:context]).to eql({some: 'extra info'})
            end
        end
    end
end
