#
# Container Image Distribution
#

FROM alpine:3.16.2

ARG PROJ_NAME
ARG PROJ_VERSION
ARG PROJ_BUILD_NUM
ARG PROJ_BUILD_DATE
ARG PROJ_REPO
ARG TARGETOS
ARG TARGETARCH

LABEL org.opencontainers.image.authors="V10 Solutions"
LABEL org.opencontainers.image.title="${PROJ_NAME}"
LABEL org.opencontainers.image.version="${PROJ_VERSION}"
LABEL org.opencontainers.image.revision="${PROJ_BUILD_NUM}"
LABEL org.opencontainers.image.created="${PROJ_BUILD_DATE}"
LABEL org.opencontainers.image.description="Container image for Distribution"
LABEL org.opencontainers.image.source="${PROJ_REPO}"

RUN apk update \
	&& apk add --no-cache "shadow" "bash" \
	&& usermod -s "$(command -v "bash")" "root"

SHELL [ \
	"bash", \
	"--noprofile", \
	"--norc", \
	"-o", "errexit", \
	"-o", "nounset", \
	"-o", "pipefail", \
	"-c" \
]

ENV LANG "C.UTF-8"
ENV LC_ALL "${LANG}"

RUN apk add --no-cache \
	"ca-certificates" \
	"curl" \
	"jq"

RUN groupadd -r -g "480" "distribution" \
	&& useradd \
		-r \
		-m \
		-s "$(command -v "nologin")" \
		-g "distribution" \
		-c "Distribution" \
		-u "480" \
		"distribution"

WORKDIR "/tmp"

RUN curl -L -f -o "registry.tar.gz" "https://github.com/distribution/distribution/releases/download/v${PROJ_VERSION}/registry_${PROJ_VERSION}_${TARGETOS}_${TARGETARCH}.tar.gz" \
	&& tar -x -f "registry.tar.gz" "registry" \
	&& chmod "755" "registry" \
	&& mv "registry" "/usr/local/bin/" \
	&& rm "registry.tar.gz"

WORKDIR "/usr/local"

RUN mkdir -p "etc/distribution" \
	&& folders=("var/lib/distribution") \
	&& for folder in "${folders[@]}"; do \
		mkdir -p "${folder}" \
		&& chmod "700" "${folder}" \
		&& chown -R "480":"480" "${folder}"; \
	done

WORKDIR "/"
