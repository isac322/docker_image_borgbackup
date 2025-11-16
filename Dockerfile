# syntax=docker/dockerfile:1.19

FROM python:3.12-alpine AS builder

ARG VERSION
ENV PYTHON_CONFIGURE_OPTS="--enable-shared"

RUN apk add --update \
    git \
    gcc musl-dev linux-headers acl-dev patchelf \
    openssl-dev \
    fuse3-dev
RUN ARCH=$(uname -m); \
    if [ "$ARCH" != "x86_64" ] && [ "$ARCH" != "aarch64" ]; then \
        apk add zlib-dev g++; \
    fi
RUN env MAKEFLAGS="-j$(nproc)" pip install --root-user-action=ignore -U scons wheel setuptools
RUN env MAKEFLAGS="-j$(nproc)" pip install --root-user-action=ignore -U --no-build-isolation staticx
RUN env MAKEFLAGS="-j$(nproc)" pip install --root-user-action=ignore -U pyinstaller

RUN git clone --depth 1 -b ${VERSION} https://github.com/borgbackup/borg.git
WORKDIR /borg

RUN env MAKEFLAGS="-j$(nproc)" pip install --root-user-action=ignore -r requirements.d/development.lock.txt
RUN env MAKEFLAGS="-j$(nproc)" python setup.py clean
RUN env MAKEFLAGS="-j$(nproc)" python setup.py clean2
RUN env MAKEFLAGS="-j$(nproc)" pip install -e .[pyfuse3]
RUN sed -i -E 's/strip=False/strip=True/' scripts/borg.exe.spec
RUN sed -i -E 's/borg.exe/borg/' scripts/borg.exe.spec
RUN env MAKEFLAGS="-j$(nproc)" pyinstaller --clean scripts/borg.exe.spec
RUN env MAKEFLAGS="-j$(nproc)" staticx --strip dist/borg dist/borg.static


FROM gcr.io/distroless/static-debian13
ENTRYPOINT ["/usr/local/bin/borg"]
COPY --link=true --from=builder /borg/dist/borg.static /usr/local/bin/borg
