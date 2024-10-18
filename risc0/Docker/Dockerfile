FROM ubuntu:24.04
RUN apt-get update; apt-get upgrade -y; apt-get --fix-missing install -y curl build-essential
RUN apt-get update
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
RUN echo 'source $HOME/.cargo/env' >> $HOME/.bashrc
ENV PATH="${PATH}:/root/.cargo/bin"
#RUN echo ${PATH}; rustup show
RUN curl -L https://risczero.com/install | bash -s -- -y
ENV PATH="${PATH}:/root/.risc0/bin/"
RUN rzup install cargo-risczero v1.0.1