namespace :debugmate do
    desc "Send fake data to webhook"
    task test: :environment do
      DebugMate::ExceptionHandler.send_test
    end
  
end
