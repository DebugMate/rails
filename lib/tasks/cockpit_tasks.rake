namespace :cockpit do
    desc "Send fake data to webhook"
    task test: :environment do
      Cockpit::ExceptionHandler.send_test
    end
  
end
