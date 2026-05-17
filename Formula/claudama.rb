class Claudama < Formula
  desc "Ollama-API-compatible server backed by the Claude Code CLI"
  homepage "https://github.com/atelpis/claudama"
  url "https://github.com/atelpis/claudama/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "4ee174de0a7d51beafea7d8b2437002774a671e79758f1ffb6f7e5213ea4f03b"
  license "MIT"
  head "https://github.com/atelpis/claudama.git", branch: "main"

  depends_on "go" => :build

  def install
    ldflags = %W[
      -s -w
      -X main.version=#{version}
      -X main.etcConfigDir=#{etc}/claudama
    ]
    system "go", "build", *std_go_args(ldflags: ldflags.join(" ")), "./cmd/claudama"

    (etc/"claudama").mkpath
    conf = etc/"claudama/conf.toml"
    conf.write <<~TOML unless conf.exist?
      # claudama config — uncomment to override defaults.
      # port = 11434
    TOML
  end

  service do
    run [opt_bin/"claudama"]
    keep_alive true

    # Ensures the service can look inside Homebrew bins, system bins, and common user paths
    environment_variables PATH: std_service_path_env + ":/usr/local/bin:/opt/homebrew/bin:~/.local/bin"

    log_path var/"log/claudama.log"
    error_log_path var/"log/claudama.log"
  end

  def caveats
    <<~EOS
      claudama forwards chat requests to the Claude Code CLI. Install it
      (see https://docs.claude.com/en/docs/claude-code) and make sure
      `claude` is on PATH.

      Default port is 11434 (Ollama's default) so existing clients work
      unchanged. If Ollama is already running on this machine, claudama
      will fail to bind — pick another port:
        mkdir -p ~/.config/claudama
        echo 'port = 11436' > ~/.config/claudama/conf.toml
        brew services restart claudama

      Per-user config (takes precedence over #{etc}/claudama/conf.toml):
        ~/.config/claudama/conf.toml

      Run as a background service:
        brew services start claudama

      Logs:
        #{var}/log/claudama.log
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/claudama -version").strip
  end
end
