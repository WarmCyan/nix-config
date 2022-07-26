{ writeShellApplication, pkgs }:
writeShellApplication {
  name = "add-jupyter-env";
  runtimeInputs = [ pkgs.micromamba ];
  text = /* bash */ ''
    micromamba install \
      jupyter \
      jupyterlab \
      nodejs \
      jupyterlab_vim \
      jupyterlab-drawio \
      dask_labextension \
      jupyterlab-lsp \
      python-language-server \
      jupyterlab_code_formatter \
      black \
      isort
      
    pip install jupyterlab-vimrc
  '';
}
