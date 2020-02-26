FROM debian:stretch
#MAINTAINER Aleksey Yaroslavcev <a.yaroslavcev@gmail.com>
#Update repo
RUN apt-get update && apt-get install -y libtool-bin libgdk-pixbuf2.0-dev p7zip-full autoconf automake autopoint bash bison bzip2 cmake flex gettext git g++ gperf intltool libffi-dev libtool libltdl-dev libssl-dev libxml-parser-perl make openssl patch perl pkg-config python ruby scons sed unzip wget xz-utils build-essential lzip

#Create devel user...
RUN useradd -m -d /home/devel -u 1000 -U -G users,tty -s /bin/bash devel

#Clone mxe repo
RUN mkdir -p /opt/mxe && \
  git clone https://github.com/mxe/mxe.git /opt/mxe && \
  chown -R devel /opt/mxe && \
  sed -i 's/i686-w64-mingw32_EH   := sjlj dw2/i686-w64-mingw32_EH   := dw2 sjlj/g' /opt/mxe/Makefile
  
#Make toolchain
USER devel
RUN cd /opt/mxe && \
  make -j`nproc` JOBS=2 mingw-w64 gcc openssl glib MXE_TARGETS=i686-w64-mingw32.shared 
  
RUN cd /opt/mxe && \
  make -j`nproc` qtbase qtcharts qtdeclarative qtquickcontrols qtquickcontrols2 qtscript qttools qttranslations MXE_TARGETS=i686-w64-mingw32.shared 

ENV PATH="/opt/mxe/usr/bin:${PATH}"
