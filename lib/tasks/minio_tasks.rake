namespace :minio do
  desc "Print the ENV variables set for the MinIO commands, if any"
  task env: :environment do
    if MinIO.configuration.nil?
      warn "You have not configured the MinIO gem with any values to generate ENV variables"
      next
    end

    puts "MINIO_ROOT_USER=#{MinIO.configuration.username}"
    puts "MINIO_ROOT_PASSWORD=#{MinIO.configuration.password}"

    true
  end

  desc "Start the MinIO object storage server, e.g. rake minio:server -- --directory=storage/minio"
  task server: :environment do
    options = {}
    if (separator_index = ARGV.index("--"))
      ARGV.slice(separator_index + 1, ARGV.length)
        .map { |pair| pair.split("=") }
        .each { |opt| options[opt[0]] = opt[1] || nil }
    end
    directory = options.delete("--directory") || options.delete("-directory") || "storage/minio"
    options.symbolize_keys!

    MinIO::Commands.server(directory, async: true, **options)
  end
end
