class Claudama < Formula
  desc "Ollama-API-compatible server backed by the Claude Code CLI"
  homepage "https://github.com/atelpis/claudama"
  version "0.1.4"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/atelpis/claudama/releases/download/v0.1.4/claudama_0.1.4_darwin_arm64.tar.gz"
      sha256 "e6d09b79d0ece83033ded9a89cdd9d4c7c1247fb6a8e6be786b857dc66ebdc2e"
    end
    on_intel do
      url "https://github.com/atelpis/claudama/releases/download/v0.1.4/claudama_0.1.4_darwin_amd64.tar.gz"
      sha256 "092787a3bd3d9640d2665cc4064fe8fadd91a8beeb34c50cf1684e64ec9a4647"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/atelpis/claudama/releases/download/v0.1.4/claudama_0.1.4_linux_arm64.tar.gz"
      sha256 "3eafabe33c3c3ff8b9188752a12c0dde0335b73abe191862399a46e8a1f5a1b8"
    end
    on_intel do
      url "https://github.com/atelpis/claudama/releases/download/v0.1.4/claudama_0.1.4_linux_amd64.tar.gz"
      sha256 "9e421db05a36947163a88a138365437dae3c6d44c8b6c0878a8568528783142f"
    end
  end

  def install
    bin.install "claudama"

    (etc/"claudama").mkpath
    conf = etc/"claudama/conf.toml"
    conf.write <<~TOML unless conf.exist?
      # claudama config — uncomment to override defaults.
      # port = 11434

      # Absolute path to the `claude` binary. Leave unset to auto-discover via
      # $PATH or well-known install locations (covers Homebrew, npm-global,
      # bun). Set this explicitly only if `claude` lives somewhere unusual
      # (e.g. nvm version dir, volta, custom npm prefix).
      # claude_path = "/Users/you/.nvm/versions/node/v22.0.0/bin/claude"
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
      (see https://docs.claude.com/en/docs/claude-code). claudama
      auto-discovers `claude` in standard locations; if you use nvm, volta,
      or a custom npm prefix, set `claude_path` in conf.toml.

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
