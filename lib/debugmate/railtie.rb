module Debugmate
  class Railtie < ::Rails::Railtie
    rake_tasks do
      load 'tasks/debugmate_tasks.rake'
    end
  end
end
