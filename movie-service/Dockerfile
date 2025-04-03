FROM python:3.8-slim

WORKDIR /app

COPY ./requirements.txt /app/requirements.txt

RUN rm -f /etc/apt/apt.conf.d/docker-clean

#RUN apt-get update \
 #   && apt-get install -y gcc \
  #  && apt-get clean \
   # && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
  && apt-get install -y --no-install-recommends gcc \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN pip install -r /app/requirements.txt \
    && rm -rf /root/.cache/pip

COPY . /app/