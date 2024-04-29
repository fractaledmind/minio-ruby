module MinIO
  module Upstream
    VERSION = "RELEASE.2024-04-18T19-09-19Z"

    # rubygems platform name => upstream release filename
    NATIVE_PLATFORMS = {
      "arm64-darwin" => "darwin-arm64/minio.#{VERSION}",
      "arm64-linux" => "linux-arm64/minio.#{VERSION}",
      "x86_64-darwin" => "darwin-amd64/minio.#{VERSION}",
      "x86_64-linux" => "linux-amd64/minio.#{VERSION}",
      "x86_64-windows" => "windows-amd64/minio.#{VERSION}"
    }
  end
end
