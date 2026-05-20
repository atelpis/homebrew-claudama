class Claudama < Formula
  desc "Ollama-API-compatible server backed by the Claude Code CLI"
  homepage "https://github.com/atelpis/claudama"
  version "0.1.6"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/atelpis/claudama/releases/download/v0.1.6/claudama_0.1.6_darwin_arm64.tar.gz"
      sha256 "42d96a790de387b55fe311a261c3d8477203da27f9a0008c4788f5c53273152f"
    end
    on_intel do
      url "https://github.com/atelpis/claudama/releases/download/v0.1.6/claudama_0.1.6_darwin_amd64.tar.gz"
      sha256 "65cb8f8a6a78c7a81680937244a0788f6b8a32e7f6fcfb72d67210dc79913c85"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/atelpis/claudama/releases/download/v0.1.6/claudama_0.1.6_linux_arm64.tar.gz"
      sha256 "7bf1f932e27d68ee50235019b675ec12cbd8e2955ae502b93af8857997ff3594"
    end
    on_intel do
      url "https://github.com/atelpis/claudama/releases/download/v0.1.6/claudama_0.1.6_linux_amd64.tar.gz"
      sha256 "fe127a7afc7d480662f02a4a585d56d6497db1b543c34b6a7d97a06bafd54e65"
    end
  end

  def install
    bin.install "claudama"

    (etc/"claudama").mkpath
    conf = etc/"claudama/conf.toml"
    conf.write <<~TOML unless conf.exist?
      # claudama config — uncomment to override defaults.
      # port = 11435

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

      Default port is 11435 so claudama can coexist with Ollama (11434)
      on the same machine — Raycast requires the Ollama app to be
      installed for its AI-provider slot to appear, even when you point
      it at claudama. In Raycast: Settings → AI → Ollama, set host to
      http://127.0.0.1:11435 and click Sync Models.

      To use a different port:
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
