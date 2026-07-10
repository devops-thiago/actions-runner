# ubuntu 26.04
FROM ubuntu@sha256:b7f48194d4d8b763a478a621cdc81c27be222ba2206ca3ca6bc42b49685f3d9e

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      curl=8.18.0-1ubuntu2.3 \
      ca-certificates=20260601~26.04.1 \
      gpg=2.4.8-4ubuntu3 \
      dirmngr=2.4.8-4ubuntu3 \
      git=1:2.53.0-1ubuntu1 \
      unzip=6.0-29ubuntu1 \
      zip=3.0-15ubuntu3 \
      wget=1.25.0-2ubuntu4 \
      jq=1.8.1-4ubuntu2 \
      tar=1.35+dfsg-4ubuntu0.2 \
      sudo=1.9.17p2-1ubuntu3 \
      software-properties-common=0.120.1 \
      openssh-client=1:10.2p1-2ubuntu3.2 \
      pkg-config=2.5.1-4 \
      libssl-dev=3.5.5-1ubuntu3.2 \
      gcc=4:15.2.0-5ubuntu1 \
      g++=4:15.2.0-5ubuntu1 \
      make=4.4.1-3 \
      build-essential=12.12ubuntu2.26.04.1 \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ARG RUNNER_VERSION=2.335.1

RUN useradd -m runner
WORKDIR /home/runner/actions-runner

RUN set -eux && \
    case "$(uname -m)" in \
      x86_64)  RUNNER_ARCH=x64 ;; \
      aarch64) RUNNER_ARCH=arm64 ;; \
      *)       echo "Unsupported arch: $(uname -m)"; exit 1 ;; \
    esac && \
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
    bash ./bin/installdependencies.sh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    chown -R runner:runner /home/runner

COPY --chown=runner:runner entrypoint.sh .

USER runner

ENTRYPOINT ["./entrypoint.sh"]
