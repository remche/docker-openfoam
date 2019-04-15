FROM debian:stretch-slim as builder
LABEL maintainer "cyrille.bonamy@legi.cnrs.fr"
ARG WM_NCOMPPROCS=10

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      cmake \
      flex \
      freeglut3-dev \
      g++ \
      gcc \
      libfl-dev \
      libgd-tools \
      libopenmpi-dev \
      libqt5opengl5-dev \
      libqt5x11extras5-dev \
      libxt-dev \
      libz-dev \
      make \
      meld \
      mercurial \
      python-dev \
      qtbase5-dev \
      qttools5-dev \
    	wget

WORKDIR /opt/openfoam/5.0/OpenFOAM-5.0
RUN wget -O /tmp/OF.tgz https://codeload.github.com/OpenFOAM/OpenFOAM-5.x/tar.gz/version-5.0 && \
    tar -xvf /tmp/OF.tgz --strip-components=1

WORKDIR /opt/openfoam/5.0/ThirdParty-5.0
RUN wget -O /tmp/TP.tgz https://codeload.github.com/OpenFOAM/ThirdParty-5.x/tar.gz/version-5.0 && \
    tar -xvf /tmp/TP.tgz  --strip-components=1

WORKDIR /opt/openfoam/5.0/OpenFOAM-5.0
RUN /bin/bash -c "source etc/bashrc; ./Allwmake"
RUN find /opt/openfoam -name "*.o" -exec rm -f {} \;


#WORKDIR /opt
#RUN /bin/bash -c "hg clone http://hg.code.sf.net/p/openfoam-extend/swak4Foam -r compile_of5.0"
#WORKDIR /opt/swak4Foam
#RUN /bin/bash -c "source /opt/openfoam/5.0/OpenFOAM-5.0/etc/bashrc && ./maintainanceScripts/compileRequirements.sh"
##COPY /opt/swak4Foam/swakConfiguration.debian  /opt/swak4Foam/swakConfiguration
#RUN /bin/bash -c "source /opt/openfoam/5.0/OpenFOAM-5.0/etc/bashrc && ./Allwmake"
#RUN /bin/bash -c "source /opt/openfoam/5.0/OpenFOAM-5.0/etc/bashrc && ./maintainanceScripts/copySwakFilesToSite.sh"

FROM debian:stretch
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      openmpi-bin \
      ssh
COPY --from=builder /opt/openfoam /opt/openfoam
WORKDIR /home/openfoam
ENV HOME /home/openfoam
USER 1000
WORKDIR /home/openfoam/local
ENTRYPOINT ["/bin/bash", "-c"]
