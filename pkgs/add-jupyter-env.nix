{ writeShellApplication, pkgs }:
writeShellApplication {
  name = "add-jupyter-env";
  runtimeInputs = [ pkgs.unstable.micromamba ];
  text = /* bash */ ''
    micromamba install \
      jupyter \
      jupyterlab \
      nodejs \
      jupyterlab_vim \
      jupyterlab-lsp \
      python-lsp-server \
      jupyterlab_code_formatter \
      black \
      isort
  '';
}
