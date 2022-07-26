# Testing package

{ writeShellApplication }:
writeShellApplication {
  name = "testing";
  text = /* bash */ ''
    echo "Hello there!"
    echo -e "\033[0;33mTesting, testing, 1, 2, 3\033[0m"
  '';
}
