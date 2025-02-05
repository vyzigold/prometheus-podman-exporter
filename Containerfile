# --- build podman exporter ---
FROM registry.access.redhat.com/ubi9:latest AS builder
ENV GOPATH=/go
ENV D=/go/src/github.com/containers/prometheus-podman-exporter

WORKDIR $D
COPY . $D/

RUN dnf install -y golang git gcc make conmon glib2-devel glibc-devel glibc-static gpgme-devel device-mapper-devel libassuan-devel
RUN make binary

# --- end build, create podman_exporter layer ---
FROM registry.access.redhat.com/ubi9:latest

RUN dnf install -y device-mapper-devel libassuan-devel
COPY --from=builder /go/src/github.com/containers/prometheus-podman-exporter/bin/prometheus-podman-exporter /bin/podman_exporter

EXPOSE 9882
USER nobody
ENTRYPOINT [ "/bin/podman_exporter" ]
