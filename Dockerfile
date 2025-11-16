# syntax=docker/dockerfile:1.19

FROM python:3.11-slim AS builder

ARG VERSION
ENV PYTHON_CONFIGURE_OPTS="--enable-shared" DEBIAN_FRONTEND=noninteractive

RUN printf 'Dir::Cache::pkgcache "";\nDir::Cache::srcpkgcache "";' > /etc/apt/apt.conf.d/00_disable-cache-files
RUN apt-get update -qq
RUN apt-get install -y --no-install-recommends \
    git \
    libacl1-dev libacl1 libssl-dev liblz4-dev libzstd-dev libxxhash-dev build-essential pkg-config \
    zlib1g-dev libbz2-dev libncurses5-dev libreadline-dev liblzma-dev libsqlite3-dev libffi-dev \
    patchelf \
    libfuse-dev fuse
RUN if ! [ "$(uname -m)" = 'x86_64' ]; then apt-get install -y --no-install-recommends cargo; fi
RUN env MAKEFLAGS="-j$(nproc)" pip install --root-user-action=ignore -U scons
RUN env MAKEFLAGS="-j$(nproc)" pip install --root-user-action=ignore -U pkgconfig pyinstaller staticx wheel

RUN git clone --depth 1 -b ${VERSION} https://github.com/borgbackup/borg.git
WORKDIR /borg

RUN env MAKEFLAGS="-j$(nproc)" pip install --root-user-action=ignore -r requirements.d/development.lock.txt
RUN env MAKEFLAGS="-j$(nproc)" python setup.py clean
RUN env MAKEFLAGS="-j$(nproc)" python setup.py clean2
RUN env MAKEFLAGS="-j$(nproc)" pip install -e .[llfuse]
RUN sed -iE 's/strip=False/strip=True/' scripts/borg.exe.spec
RUN sed -iE 's/borg.exe/borg/' scripts/borg.exe.spec
RUN env MAKEFLAGS="-j$(nproc)" pyinstaller --clean scripts/borg.exe.spec
RUN env MAKEFLAGS="-j$(nproc)" staticx --strip dist/borg dist/borg.static


FROM gcr.io/distroless/static-debian13
ENTRYPOINT ["/usr/local/bin/borg"]
COPY --link=true --from=builder /borg/dist/borg.static /usr/local/bin/borg
