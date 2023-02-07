# original: https://github.com/WildfireXIII/session-notes-manager/blob/master/notes

# TODO: a flag to just print the contents of the log with the given name to stdout
# (this could be used to create "watch engilog --read my_log | rg "TODO" and so
# on.)
# TODO: a flag to list the logs to stdout
# TODO: it would be cool if we could have nvim open the log and set the working
# directory to a project directory that's listed at the top of the file.
  # NOTE: in order for this to work, you'd have to allow specifying multiple 
  # directories, where you list them per hostname (so engilog would have to
  # handle this based on what the current hostname was)
# TODO: so yeah, the engineering log needs to have some metadata at the top
# TODO: there should also be some syntax to allow exporting specifically
# indicated sections (e.g. allow it to be a decision log as well. and allow
# listing those out and exporting each one to a file perhaps)


# IDEA: syntax for file that allows "injecting" todos into the top of the file


{ pkgs, builders }:
builders.writeTemplatedShellApplication {
  name = "engilog";
  version = "0.1.0";
  description = "Tool for keeping engineering logs - off the cuff notes, decisions, and brain context while working.";
  usage = "engilog [-h|--help] [--version]";
  parameters = {};
  text = /* bash */ ''
  '';
}
