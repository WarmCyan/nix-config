{ writeShellApplication, pkgs }:
writeShellApplication {
  name = "gpg-without-tty";
  text = /* bash */ ''
    # https://stackoverflow.com/questions/38384957/prevent-git-from-asking-for-the-gnupg-password-during-signing-a-commit

    export pflag=""
    # create dynamic `--passphrase` flag to insert into the final command if the passphrase variable is not empty.
    if [[ -n "$GPG_PASS" ]];  then
      pflag="--passphrase ${GPG_PASS}"
    fi

    # "<&0" → use same stdin as the one originally piped to script
    # "$@" → pass all script arguments to actual command

    gpg --yes --batch $pflag $@ <&0

    exit $?
  '';
};
