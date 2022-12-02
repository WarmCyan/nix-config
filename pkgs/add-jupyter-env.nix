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
      ipydrawio \
      dask_labextension \
      jupyterlab-lsp \
      python-lsp-server \
      jupyterlab_code_formatter \
      black \
      isort
      
    pip install jupyterlab-vimrc
  '';
}
