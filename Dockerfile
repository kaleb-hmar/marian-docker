RUN apt-get update && apt-get install -y \
                build-essential \
                git-core \
                pkg-config \
                libtool \
                zlib1g-dev \
                libbz2-dev \
                cmake \
                automake \
                python-dev \
                perl \
                libsparsehash-dev \
                wget \
            && rm -rf /var/lib/apt/lists/*

RUN wget http://sourceforge.net/projects/boost/files/boost/1.58.0/boost_1_58_0.tar.gz
RUN tar -zxf boost_1_58_0.tar.gz
WORKDIR boost_1_58_0/
RUN ./bootstrap.sh
RUN ./b2 install
WORKDIR /

RUN git clone https://github.com/marian-nmt/marian-dev

ENV MARIANPATH /marian-dev

WORKDIR $MARIANPATH
RUN mkdir -p build
WORKDIR $MARIANPATH/build
RUN cmake .. $MARIANPATH -DCOMPILE_CUDA=off -DCOMPILE_CPU=on -DCOMPILE_SERVER=on && make -j4
RUN mkdir model
ADD https://www.dropbox.com/s/6f0vh3wkaq6ba58/lus-en.zip?dl=1 model/

WORKDIR $MARIANPATH/build/model
RUN unzip lus-en.zip && rm -rf lus-en.zip
WORKDIR $MARIANPATH/build

RUN ls
EXPOSE 8080

CMD ./marian-server --port 8080 -m model/model.npz -v model/vocab.yml model/vocab.yml