require_relative "upstream"

module MinIO
  module Commands
    DEFAULT_DIR = File.expand_path(File.join(__dir__, "..", "..", "exe"))
    GEM_NAME = "minio"

    # raised when the host platform is not supported by upstream minio's binary releases
    class UnsupportedPlatformException < StandardError
    end

    # raised when the minio executable could not be found where we expected it to be
    class ExecutableNotFoundException < StandardError
    end

    # raised when MINIO_INSTALL_DIR does not exist
    class DirectoryNotFoundException < StandardError
    end

    class << self
      def platform
        [:cpu, :os].map { |m| Gem::Platform.local.send(m) }.join("-")
      end

      def executable(exe_path: DEFAULT_DIR)
        minio_install_dir = ENV["MINIO_INSTALL_DIR"]
        if minio_install_dir
          if File.directory?(minio_install_dir)
            warn "NOTE: using MINIO_INSTALL_DIR to find minio executable: #{minio_install_dir}"
            exe_path = minio_install_dir
            exe_file = File.expand_path(File.join(minio_install_dir, "minio"))
          else
            raise DirectoryNotFoundException, <<~MESSAGE
              MINIO_INSTALL_DIR is set to #{minio_install_dir}, but that directory does not exist.
            MESSAGE
          end
        else
          if MinIO::Upstream::NATIVE_PLATFORMS.keys.none? { |p| Gem::Platform.match_gem?(Gem::Platform.new(p), GEM_NAME) }
            raise UnsupportedPlatformException, <<~MESSAGE
              minio-ruby does not support the #{platform} platform
              Please install minio following instructions at https://min.io/download?license=agpl
            MESSAGE
          end

          exe_file = Dir.glob(File.expand_path(File.join(exe_path, "*", "minio"))).find do |f|
            Gem::Platform.match_gem?(Gem::Platform.new(File.basename(File.dirname(f))), GEM_NAME)
          end
        end

        if exe_file.nil? || !File.exist?(exe_file)
          raise ExecutableNotFoundException, <<~MESSAGE
            Cannot find the minio executable for #{platform} in #{exe_path}

            If you're using bundler, please make sure you're on the latest bundler version:

                gem install bundler
                bundle update --bundler

            Then make sure your lock file includes this platform by running:

                bundle lock --add-platform #{platform}
                bundle install

            See `bundle lock --help` output for details.

            If you're still seeing this message after taking those steps, try running
            `bundle config` and ensure `force_ruby_platform` isn't set to `true`. See
            https://github.com/fractaledmind/minio-ruby#check-bundle_force_ruby_platform
            for more details.
          MESSAGE
        end

        exe_file
      end

      def server(directory, async: false, **argv)
        if MinIO.configuration
          ENV["MINIO_ROOT_USER"] ||= MinIO.configuration.username
          ENV["MINIO_ROOT_PASSWORD"] ||= MinIO.configuration.password
        end

        cmd = [executable, "server", *argv.stringify_keys, directory].flatten.compact
        puts cmd.inspect if ENV["DEBUG"]

        run(cmd, async: async)
      end

      private

      def run(cmd, async: false)
        if async
          # To release the resources of the Ruby process, just fork and exit.
          # The forked process executes litestream and replaces itself.
          exec(*cmd) if fork.nil?
        else
          `#{cmd.join(" ")}`
        end
      end
    end
  end
end
