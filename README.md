# Docker image for borgbackup

[1]: https://hub.docker.com/r/isac322/borgbackup
[2]: https://pypi.org/project/borgbackup/
[3]: https://github.com/isac322/docker_image_borgbackup

[![Docker Pulls](https://img.shields.io/docker/pulls/isac322/borgbackup?logo=docker&style=flat-square)][1]
[![Docker Image Size (tag)](https://img.shields.io/docker/image-size/isac322/borgbackup/1?logo=docker&style=flat-square)][1]
[![PyPI](https://img.shields.io/pypi/v/borgbackup?label=borgbackup&logo=python&style=flat-square)][2]
[![PyPI - Python Version](https://img.shields.io/pypi/pyversions/borgbackup?logo=python&style=flat-square)][2]
[![GitHub last commit (branch)](https://img.shields.io/github/last-commit/isac322/docker_image_borgbackup/master?logo=github&style=flat-square)][3]
[![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/isac322/docker_image_borgbackup/publish.yaml?branch=master&style=flat-square&logo=github)
][3]

> ### Images automatically follow upstream via dependabot. 

Supported platform: `linux/amd64`, `linux/arm64`, `linux/arm/v7`

Based on [distroless](https://github.com/GoogleContainerTools/distroless) and supports fuse.

## Tag format

`isac322/borgbackup:<borg_version>`

## Command

Default Entrypoint of image is `borg`.

## How to run

`docker run --rm -ti isac322/borgbackup:1 debug info` will print borg version and debugging infomation.

Please refer [official borgbackup document](https://borgbackup.readthedocs.io/en/stable/)
