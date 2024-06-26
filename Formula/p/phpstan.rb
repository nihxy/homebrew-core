class Phpstan < Formula
  desc "PHP Static Analysis Tool"
  homepage "https://github.com/phpstan/phpstan"
  url "https://github.com/phpstan/phpstan/releases/download/1.11.1/phpstan.phar"
  sha256 "0d80020ccbd5513161935e2ca7a51c28c53052421724ef019c34c178e4aa2fcb"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "54031d57dcdf02c3cd392070d07f83ac0455c95ec24fb2371b24f0bb034ad033"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "54031d57dcdf02c3cd392070d07f83ac0455c95ec24fb2371b24f0bb034ad033"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "54031d57dcdf02c3cd392070d07f83ac0455c95ec24fb2371b24f0bb034ad033"
    sha256 cellar: :any_skip_relocation, sonoma:         "018ed9d2ae5040e469ab8da69988fd1ba90f86cb36b0f9bf28ea04b6e06751a2"
    sha256 cellar: :any_skip_relocation, ventura:        "018ed9d2ae5040e469ab8da69988fd1ba90f86cb36b0f9bf28ea04b6e06751a2"
    sha256 cellar: :any_skip_relocation, monterey:       "018ed9d2ae5040e469ab8da69988fd1ba90f86cb36b0f9bf28ea04b6e06751a2"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "54031d57dcdf02c3cd392070d07f83ac0455c95ec24fb2371b24f0bb034ad033"
  end

  depends_on "php" => :test

  # Keg-relocation breaks the formula when it replaces `/usr/local` with a non-default prefix
  on_macos do
    on_intel do
      pour_bottle? only_if: :default_prefix
    end
  end

  def install
    bin.install "phpstan.phar" => "phpstan"
  end

  test do
    (testpath/"src/autoload.php").write <<~EOS
      <?php
      spl_autoload_register(
          function($class) {
              static $classes = null;
              if ($classes === null) {
                  $classes = array(
                      'email' => '/Email.php'
                  );
              }
              $cn = strtolower($class);
              if (isset($classes[$cn])) {
                  require __DIR__ . $classes[$cn];
              }
          },
          true,
          false
      );
    EOS

    (testpath/"src/Email.php").write <<~EOS
      <?php
        declare(strict_types=1);

        final class Email
        {
            private string $email;

            private function __construct(string $email)
            {
                $this->ensureIsValidEmail($email);

                $this->email = $email;
            }

            public static function fromString(string $email): self
            {
                return new self($email);
            }

            public function __toString(): string
            {
                return $this->email;
            }

            private function ensureIsValidEmail(string $email): void
            {
                if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
                    throw new InvalidArgumentException(
                        sprintf(
                            '"%s" is not a valid email address',
                            $email
                        )
                    );
                }
            }
        }
    EOS
    assert_match(/^\n \[OK\] No errors/,
      shell_output("#{bin}/phpstan analyse --level max --autoload-file src/autoload.php src/Email.php"))
  end
end
