#--------- Generic stuff all our Dockerfiles should start with so we get caching ------------
FROM ubuntu:trusty
MAINTAINER Tim Sutton<tim@linfiniti.com>

RUN  export DEBIAN_FRONTEND=noninteractive
ENV  DEBIAN_FRONTEND noninteractive
RUN  dpkg-divert --local --rename --add /sbin/initctl
#RUN  ln -s /bin/true /sbin/initctl

# Use local cached debs from host (saves your bandwidth!)
# Change ip below to that of your apt-cacher-ng host
# Or comment this line out if you do not with to use caching
ADD 71-apt-cacher-ng /etc/apt/apt.conf.d/71-apt-cacher-ng

RUN apt-get -y update

#-------------Application Specific Stuff ----------------------------------------------------

RUN apt-get -y install libpq5 python-gdal python-geoip \
    python python-dev python-distribute python-pip \
    python-psycopg2 rpl \
    libblas3gf libc6 libamd2.3.1 libumfpack5.6.2 \
    libgcc1 libgfortran3 liblapack3gf libstdc++6 \
    build-essential gfortran libatlas-dev libjpeg-dev libfreetype6-dev \
    python python-all-dev gcc g++ libblas-dev liblapack-dev libevent-dev \
    binutils libproj-dev gdal-bin libgeo-proj4-perl libjson0-dev git

RUN ln -s /usr/lib/x86_64-linux-gnu/libjpeg.so /usr/lib
RUN ln -s /usr/lib/x86_64-linux-gnu/libfreetype.so /usr/lib
RUN ln -s /usr/lib/x86_64-linux-gnu/libz.so /usr/lib

RUN mkdir /home/web
WORKDIR /home/web
RUN git clone https://github.com/cccs-web/mezzanine

WORKDIR /tmp
ADD REQUIREMENTS.txt /REQUIREMENTS.txt
RUN cat /REQUIREMENTS.txt | grep -v psycopg2 > /REQUIREMENTS-cleaned.txt
RUN pip install -r /REQUIREMENTS-cleaned.txt

ENTRYPOINT ["uwsgi", "--ini", "/home/web/docker-prod/uwsgi.conf"]
