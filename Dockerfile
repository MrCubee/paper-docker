ARG PAPER_VERSION=1.21.8
ARG PAPER_BUILD=latest
ARG JAVA_MAJOR=21
ARG DL_USER_AGENT="paper-docker"

FROM alpine AS downloader
ARG PAPER_VERSION
ARG PAPER_BUILD
ARG DL_USER_AGENT
RUN apk add --no-cache curl jq ca-certificates && update-ca-certificates
RUN set -eux; \
    API="https://api.papermc.io/v2/projects/paper/versions/${PAPER_VERSION}"; \
    if [ "${PAPER_BUILD}" = "latest" ]; then \
      BUILD="$(curl -fsSL -H "User-Agent: ${DL_USER_AGENT}" "${API}/builds" | jq '[.builds[].build] | max')"; \
    else \
      BUILD="${PAPER_BUILD}"; \
    fi; \
    FILE="$(curl -fsSL -H "User-Agent: ${DL_USER_AGENT}" "${API}/builds/${BUILD}" | jq -r '.downloads.application.name')"; \
    URL="${API}/builds/${BUILD}/downloads/${FILE}"; \
    mkdir -p /opt/paper; \
    curl -fSL -H "User-Agent: ${DL_USER_AGENT}" -o "/opt/paper/${FILE}" "${URL}"; \
    ln -s "/opt/paper/${FILE}" /opt/paper/paper-server.jar

FROM alpine
ARG JAVA_MAJOR
RUN apk add --no-cache "openjdk${JAVA_MAJOR}" && mkdir -p /usr/local/bin
COPY --from=downloader /opt/paper /opt/paper
COPY ./start.sh /usr/local/bin/start-paper
RUN chmod ugo=rx /usr/local/bin/start-paper
WORKDIR /data
EXPOSE 25565/tcp
EXPOSE 25565/udp
EXPOSE 25575/tcp
ENTRYPOINT ["/usr/local/bin/start-paper"]
