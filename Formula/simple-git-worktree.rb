class SimpleGitWorktree < Formula
  desc "Simple git worktree manager"
  homepage "https://github.com/silasvasconcelos/simple-git-worktreee"
  url "https://github.com/silasvasconcelos/simple-git-worktreee/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "PLACEHOLDER"
  license "MIT"

  depends_on "git"

  def install
    bin.install "bin/git-wt"
  end

  def post_install
    system "git", "config", "--global", "alias.wt", "!git-wt"
  end

  test do
    assert_match "git-wt", shell_output("#{bin}/git-wt version")
  end
end
