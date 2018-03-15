FROM nvidia/cuda:8.0-cudnn7-devel-ubuntu16.04

MAINTAINER chenaoki <chenaoki@gmail.com>

RUN echo "now building"

RUN apt-get update && apt-get -y install \
                   build-essential \
                   git vim curl wget zsh make ffmpeg wget \
                   zlib1g-dev \
                   libssl-dev \
                   libbz2-dev \
                   libreadline-dev \
                   libsqlite3-dev \
                   llvm \
                   libncurses5-dev \
                   libncursesw5-dev \
                   libpng-dev  

USER root
ENV HOME  /root
ENV NOTEBOOK_HOME $HOME/notebooks

WORKDIR $HOME 
RUN git clone git://github.com/yyuu/pyenv.git .pyenv
ENV PYENV_ROOT $HOME/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH

RUN pyenv install anaconda3-4.1.1
RUN pyenv global anaconda3-4.1.1
RUN pyenv rehash

RUN conda update -y conda
RUN conda install -y accelerate 
RUN conda install numpy
RUN conda install -c intel mkl

RUN echo "cloning dotfiles"
WORKDIR $HOME
RUN git clone https://github.com/chenaoki/dotfiles.git
WORKDIR $HOME/dotfiles
RUN python install.py

# Jupyter Notebook Settings
RUN jupyter notebook --generate-config
RUN echo "c.NotebookApp.ip = '*'" >> /root/.jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.port = 8888" >> /root/.jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.open_browser = False" >> /root/.jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.notebook_dir = '$NOTEBOOK_HOME'" >> /root/.jupyter/jupyter_notebook_config.py

RUN mkdir -p $NOTEBOOK_HOME
WORKDIR $NOTEBOOK_HOME
#RUN pyenv local anaconda3-4.1.1/envs/tensorflow
RUN pip install --upgrade pip
#RUN pip install opencv-python
#RUN apt install -y libsm6 libxext6 libxrender1
RUN pip install --ignore-installed --upgrade tensorflow 
RUN conda install -c menpo opencv3
RUN apt-get -y install libgtk2.0-0 python-qt4 
RUN pip install tensorboard

ADD import_test.ipynb $NOTEBOOK_HOME
CMD ["sh", "-c", "jupyter notebook > $NOTEBOOK_HOME/log.txt 2>&1"]

