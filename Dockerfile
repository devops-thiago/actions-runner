FROM ubuntu@sha256:53958ec7b67c2c9355df922dd08dbf0360611f8c3cdb656875e81873db9ffdba # 26.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      curl ca-certificates gpg dirmngr git unzip zip \
      wget jq tar sudo software-properties-common \
      openssh-client pkg-config libssl-dev \
      gcc g++ make build-essential \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ARG RUNNER_VERSION=2.334.0
ARG RUNNER_ARCH=x64

RUN useradd -m runner
WORKDIR /home/runner/actions-runner

RUN set -eux && \
    RUNNER_FILE="actions-runner-linux-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz" && \
    curl -fsSL -o "${RUNNER_FILE}" \
      "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/${RUNNER_FILE}" && \
    EXPECTED_SHA=$(curl -fsSL \
      "https://api.github.com/repos/actions/runner/releases/tags/v${RUNNER_VERSION}" \
      | jq -r '.body' \
      | grep "${RUNNER_FILE}" \
      | grep -oE '[a-f0-9]{64}' \
      | head -1) && \
    test -n "${EXPECTED_SHA}" && \
    echo "${EXPECTED_SHA}  ${RUNNER_FILE}" | sha256sum -c && \
    tar xzf "${RUNNER_FILE}" && \
    rm "${RUNNER_FILE}" && \
    ./bin/installdependencies.sh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    chown -R runner:runner /home/runner

COPY --chown=runner:runner entrypoint.sh .

USER runner

ENTRYPOINT ["./entrypoint.sh"]
