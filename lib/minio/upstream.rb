module MinIO
  module Upstream
    VERSION = "RELEASE.2024-04-28T17-53-50Z"

    # rubygems platform name => upstream release filename
    NATIVE_PLATFORMS = {
      "arm64-darwin" => "darwin-arm64/minio.#{VERSION}",
      "arm64-linux" => "linux-arm64/minio.#{VERSION}",
      "aarch64-linux" => "linux-arm64/minio.#{VERSION}",
      "x86_64-darwin" => "darwin-amd64/minio.#{VERSION}",
      "x86_64-linux" => "linux-amd64/minio.#{VERSION}",
      "x64-mingw32" => "windows-amd64/minio.#{VERSION}",
      "x64-mingw-ucrt" => "windows-amd64/minio.#{VERSION}"
    }
  end
end
