require "test_helper"
require "rake"

class TestMinIOTasks < ActiveSupport::TestCase
  def setup
    Rake.application.rake_require "tasks/minio_tasks"
    Rake::Task.define_task(:environment)
    Rake::Task["minio:env"].reenable
    Rake::Task["minio:server"].reenable
  end

  def teardown
    MinIO.configuration = nil
    ARGV.replace []
  end

  class TestEnvTask < TestMinIOTasks
    def test_env_task_when_nothing_configured_warns
      out, err = capture_io do
        Rake.application.invoke_task "minio:env"
      end

      assert_equal "", out
      assert_equal "You have not configured the MinIO gem with any values to generate ENV variables\n", err
    end
  end

  class TestServerTask < TestMinIOTasks
    def test_server_task_with_only_database_using_single_dash
      ARGV.replace ["--", "-directory=tmp/minio"]
      fake = Minitest::Mock.new
      fake.expect :call, nil, ["tmp/minio"], async: true
      MinIO::Commands.stub :server, fake do
        Rake.application.invoke_task "minio:server"
      end
      fake.verify
    end

    def test_server_task_with_only_database_using_double_dash
      ARGV.replace ["--", "--directory=tmp/minio"]
      fake = Minitest::Mock.new
      fake.expect :call, nil, ["tmp/minio"], async: true
      MinIO::Commands.stub :server, fake do
        Rake.application.invoke_task "minio:server"
      end
      fake.verify
    end

    def test_server_task_with_arguments
      ARGV.replace ["--", "-directory=tmp/minio", "--quiet"]
      fake = Minitest::Mock.new
      fake.expect :call, nil, ["tmp/minio"], async: true, "--quiet": nil
      MinIO::Commands.stub :server, fake do
        Rake.application.invoke_task "minio:server"
      end
      fake.verify
    end

    def test_server_task_with_arguments_without_separator
      ARGV.replace ["-directory=tmp/minio"]
      fake = Minitest::Mock.new
      fake.expect :call, nil, ["storage/minio"], async: true
      MinIO::Commands.stub :server, fake do
        Rake.application.invoke_task "minio:server"
      end
      fake.verify
    end
  end
end
