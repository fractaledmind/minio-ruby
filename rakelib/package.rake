#
#  Rake tasks to manage native gem packages with binary executables from minio/minio
#
#  TL;DR: run "rake package"
#
#  The native platform gems (defined by MinIO::Upstream::NATIVE_PLATFORMS) will each contain
#  two files in addition to what the vanilla ruby gem contains:
#
#     exe/
#     ├── minio                             #  generic ruby script to find and run the binary
#     └── <Gem::Platform architecture name>/
#         └── minio                         #  the minio binary executable
#
#  The ruby script `exe/minio` is installed into the user's path, and it simply locates the
#  binary and executes it. Note that this script is required because rubygems requires that
#  executables declared in a gemspec must be Ruby scripts.
#
#  As a concrete example, an x86_64-linux system will see these files on disk after installing
#  minio-0.x.x-x86_64-linux.gem:
#
#     exe/
#     ├── minio
#     └── x86_64-linux/
#         └── minio
#
#  So the full set of gem files created will be:
#
#  - pkg/minio-1.0.0.gem
#  - pkg/minio-1.0.0-arm64-linux.gem
#  - pkg/minio-1.0.0-arm64-darwin.gem
#  - pkg/minio-1.0.0-x86_64-darwin.gem
#  - pkg/minio-1.0.0-x86_64-linux.gem
#
#  Note that in addition to the native gems, a vanilla "ruby" gem will also be created without
#  either the `exe/minio` script or a binary executable present.
#
#
#  New rake tasks created:
#
#  - rake gem:ruby           # Build the ruby gem
#  - rake gem:arm64-linux  # Build the aarch64-linux gem
#  - rake gem:arm64-darwin   # Build the arm64-darwin gem
#  - rake gem:x86_64-darwin  # Build the x86_64-darwin gem
#  - rake gem:x86_64-linux   # Build the x86_64-linux gem
#  - rake download           # Download all minio binaries
#
#  Modified rake tasks:
#
#  - rake gem                # Build all the gem files
#  - rake package            # Build all the gem files (same as `gem`)
#  - rake repackage          # Force a rebuild of all the gem files
#
#  Note also that the binary executables will be lazily downloaded when needed, but you can
#  explicitly download them with the `rake download` command.
#
require "rubygems/package"
require "rubygems/package_task"
require "open-uri"
require "zlib"
require "zip"
require_relative "../lib/minio/upstream"

def minio_download_url(filename)
  "https://dl.min.io/server/minio/release/#{filename}"
end

MINIO_RAILS_GEMSPEC = Bundler.load_gemspec("minio.gemspec")

gem_path = Gem::PackageTask.new(MINIO_RAILS_GEMSPEC).define
desc "Build the ruby gem"
task "gem:ruby" => [gem_path]

exepaths = []
MinIO::Upstream::NATIVE_PLATFORMS.each do |platform, filename|
  MINIO_RAILS_GEMSPEC.dup.tap do |gemspec|
    exedir = File.join(gemspec.bindir, platform) # "exe/x86_64-linux"
    exepath = File.join(exedir, "minio") # "exe/x86_64-linux/minio"
    exepaths << exepath

    # modify a copy of the gemspec to include the native executable
    gemspec.platform = platform
    gemspec.files += [exepath, "LICENSE-DEPENDENCIES"]

    # create a package task
    gem_path = Gem::PackageTask.new(gemspec).define
    desc "Build the #{platform} gem"
    task "gem:#{platform}" => [gem_path]

    directory exedir
    file exepath => [exedir] do
      release_url = minio_download_url(filename)
      warn "Downloading #{exepath} from #{release_url} ..."

      # lazy, but fine for now.
      URI.open(release_url) do |remote| # standard:disable Security/Open
        if release_url.end_with?(".zip")
          Zip::File.open_buffer(remote) do |zip_file|
            zip_file.extract("minio", exepath)
          end
        elsif release_url.end_with?(".gz")
          Zlib::GzipReader.wrap(remote) do |gz|
            Gem::Package::TarReader.new(gz) do |reader|
              reader.seek("minio") do |file|
                File.binwrite(exepath, file.read)
              end
            end
          end
        else
          File.binwrite(exepath, remote.read)
        end
      end
      FileUtils.chmod(0o755, exepath, verbose: true)
    end
  end
end

desc "Download all minio binaries"
task "download" => exepaths
