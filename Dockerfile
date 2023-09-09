# syntax=docker/dockerfile:labs
ARG GO_VERSION="1.20"
# 1. Build go2rtc binary
FROM --platform=$BUILDPLATFORM golang:${GO_VERSION}-alpine AS build
ARG TARGETPLATFORM
ARG TARGETOS
ARG TARGETARCH
ENV GOOS=${TARGETOS}
ENV GOARCH=${TARGETARCH}
WORKDIR /build
# Cache dependencies
COPY go.mod go.sum ./
RUN --mount=type=cache,target=/root/.cache/go-build go mod download
COPY . .
RUN --mount=type=cache,target=/root/.cache/go-build CGO_ENABLED=0 go build -o rlive -ldflags "-s -w" -trimpath
# 2. Collect all files
FROM ubuntu:20.04
COPY --from=build /build/rlive /apps/rlive
VOLUME /apps
WORKDIR /apps
EXPOSE 8443
CMD ["/apps/rlive", "-static", "/apps/static", "-groups", "/apps/groups", "-http", "8443"]