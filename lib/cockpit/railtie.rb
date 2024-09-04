module Cockpit
  class Railtie < ::Rails::Railtie
    rake_tasks do
      load 'tasks/cockpit_tasks.rake'
    end
  end
end
