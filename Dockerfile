FROM ubuntu

SHELL ["/usr/bin/bash", "-c"]

RUN apt-get update && apt-get install -y \
    build-essential \
    zlib1g-dev \
    libssl-dev \
    libncurses-dev \
    libffi-dev \
    libsqlite3-dev \
    libreadline-dev \
    libbz2-dev \
    git \
    apt-transport-https \
    ca-certificates curl \
    gnupg

RUN curl -sLf --retry 3 --tlsv1.2 --proto "=https" 'https://packages.doppler.com/public/cli/gpg.DE2A7741A397C129.key' | apt-key add - && \
    echo "deb https://packages.doppler.com/public/cli/deb/debian any-version main" | tee /etc/apt/sources.list.d/doppler-cli.list && \
    apt-get update && \
    apt-get -y install doppler

RUN cd /tmp && \
    git clone https://github.com/aws/aws-elastic-beanstalk-cli-setup.git && \
    ./aws-elastic-beanstalk-cli-setup/scripts/bundled_installer && \
    rm -fr aws-elastic-beanstalk-cli-setup

ENV PATH="/root/.ebcli-virtual-env/executables:/root/.pyenv/versions/3.7.2/bin:$PATH"

RUN pip install --upgrade pip && \
    pip install --upgrade awsebcli

WORKDIR /usr/src/app

COPY bin/doppler-secrets-sync /usr/local/bin/doppler-secrets-sync
COPY ./app /usr/src/app

CMD ["doppler-secrets-sync"]