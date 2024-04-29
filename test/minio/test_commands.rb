require "test_helper"

class TestCommands < ActiveSupport::TestCase
  def run
    result = nil
    MinIO::Commands.stub :fork, nil do
      MinIO::Commands.stub :executable, "exe/test/minio" do
        capture_io { result = super }
      end
    end
    result
  end

  def teardown
    MinIO.configuration = nil
    ENV["MINIO_ROOT_USER"] = nil
    ENV["MINIO_ROOT_PASSWORD"] = nil
  end

  class TestServerCommand < TestCommands
    def test_server_with_no_options
      stub = proc do |cmd, async|
        executable, command, *argv = cmd
        assert_match Regexp.new("exe/test/minio"), executable
        assert_equal "server", command
        assert_equal 1, argv.size
        assert_equal "/mnt/data", argv[0]
      end
      MinIO::Commands.stub :run, stub do
        MinIO::Commands.server("/mnt/data")
      end
    end

    def test_server_with_boolean_option
      stub = proc do |cmd, async|
        executable, command, *argv = cmd
        assert_match Regexp.new("exe/test/minio"), executable
        assert_equal "server", command
        assert_equal 2, argv.size
        assert_equal "--quiet", argv[0]
        assert_equal "/mnt/data", argv[1]
      end
      MinIO::Commands.stub :run, stub do
        MinIO::Commands.server("/mnt/data", "--quiet" => nil)
      end
    end

    def test_server_with_string_option
      stub = proc do |cmd, async|
        executable, command, *argv = cmd
        assert_match Regexp.new("exe/test/minio"), executable
        assert_equal "server", command
        assert_equal 3, argv.size
        assert_equal "--console-address", argv[0]
        assert_equal ":9001", argv[1]
        assert_equal "/mnt/data", argv[2]
      end
      MinIO::Commands.stub :run, stub do
        MinIO::Commands.server("/mnt/data", "--console-address" => ":9001")
      end
    end

    def test_server_sets_username_env_var_from_config_when_env_var_not_set
      MinIO.configure do |config|
        config.username = "user"
      end

      MinIO::Commands.stub :run, nil do
        MinIO::Commands.server("/mnt/data")
      end

      assert_equal "user", ENV["MINIO_ROOT_USER"]
      assert_nil ENV["MINIO_ROOT_PASSWORD"]
    end

    def test_server_sets_password_env_var_from_config_when_env_var_not_set
      MinIO.configure do |config|
        config.password = "secret"
      end

      MinIO::Commands.stub :run, nil do
        MinIO::Commands.server("/mnt/data")
      end

      assert_nil ENV["MINIO_ROOT_USER"]
      assert_equal "secret", ENV["MINIO_ROOT_PASSWORD"]
    end

    def test_server_sets_all_env_vars_from_config_when_env_vars_not_set
      MinIO.configure do |config|
        config.username = "user"
        config.password = "secret"
      end

      MinIO::Commands.stub :run, nil do
        MinIO::Commands.server("/mnt/data")
      end

      assert_equal "user", ENV["MINIO_ROOT_USER"]
      assert_equal "secret", ENV["MINIO_ROOT_PASSWORD"]
    end

    def test_server_does_not_set_env_var_from_config_when_env_vars_already_set
      ENV["MINIO_ROOT_USER"] = "original_user"
      ENV["MINIO_ROOT_PASSWORD"] = "original_secret"

      MinIO.configure do |config|
        config.username = "user"
        config.password = "secret"
      end

      MinIO::Commands.stub :run, nil do
        MinIO::Commands.server("/mnt/data")
      end

      assert_equal "original_user", ENV["MINIO_ROOT_USER"]
      assert_equal "original_secret", ENV["MINIO_ROOT_PASSWORD"]
    end
  end
end
