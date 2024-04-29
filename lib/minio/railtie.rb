# frozen_string_literal: true

require "rails/railtie"

module MinIO
  class Railtie < ::Rails::Railtie
    # Load the `minio:*` Rake task into the host Rails app
    rake_tasks do
      load "tasks/minio_tasks.rake"
    end
  end
end
