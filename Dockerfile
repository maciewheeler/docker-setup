FROM --platform=linux/amd64 python:3.8-slim

RUN echo 'Updates and installs gcc'
RUN apt-get update -y && apt-get install -y gcc
RUN python -m pip install --upgrade pip

RUN echo 'Adding code and file dependencies'
COPY src /app/src
COPY notebooks /app/notebooks
COPY data /app/data
COPY docker-entrypoint.sh /
COPY requirements.txt /
COPY cloudformation.yml /app

RUN echo "Installing Python packages."
RUN pip install -r /requirements.txt
RUN chmod +x /docker-entrypoint.sh

RUN echo 'Exposing port 8888 for Jupyter Notebooks.'
EXPOSE 8888:8888

WORKDIR /app

RUN echo 'Setting ENTRYPOINT to /docker-entrypoint.sh.'
ENTRYPOINT ["/docker-entrypoint.sh"]
