class Claudama < Formula
  desc "Ollama-API-compatible server backed by the Claude Code CLI"
  homepage "https://github.com/atelpis/claudama"
  url "https://github.com/atelpis/claudama/archive/refs/tags/v0.1.3.tar.gz"
  sha256 "fcded0ad737222d3040d65d498d6f0e39b7ad85cfaf2d4bc186d753caf154ca8"
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

      # Absolute path to the `claude` binary. Leave unset to resolve via $PATH.
      # Required when running under `brew services`, since launchd does not
      # inherit your shell's PATH. Find yours with `which claude`.
      # claude_path = "/usr/local/bin/claude"
    TOML
  end

  service do
    run [opt_bin/"claudama"]
    keep_alive true
    log_path var/"log/claudama.log"
    error_log_path var/"log/claudama.log"
  end

  def caveats
    <<~EOS
      claudama forwards chat requests to the Claude Code CLI. Install it
      (see https://docs.claude.com/en/docs/claude-code).

      If running under `brew services`, set the absolute path to `claude`
      in conf.toml — launchd does not inherit your shell's PATH:
        claude_path = "$(which claude)"
      (Find your path with `which claude` in a normal terminal, then paste
      it into #{etc}/claudama/conf.toml or ~/.config/claudama/conf.toml.)

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
