# Debian Docker-in-Docker Coder Template

A Docker-in-Docker workspace base template meant for use by developers using
remote development workspaces to develop, test, and build containerized apps.

## Purpose

This image was created to satisfy the author's preference for building software
using remote development environments and within Debian Slim based containers.

This image provides boilerplate libraries and services for buiding containerized
software stacks.

## Getting Started

Refer to the [Coder Docs](https://coder.com/docs/v2/latest) to deploy Coder.

Once Coder is running, create a new Docker workspace template based off of this
image. Make any desired modifications to the build context for the workspace
template.

## Find Us

* [GitHub](https://github.com/somerled-softworks/coder-templates)

## Versioning

This image follows major releases of the [Debian Linux container](https://hub.docker.com/_/debian).

Each new tagged release will correspond to Debian linux major versions starting
with version 11 (bullseye).

## Authors

* **Richard Macdonald** - *Initial work* - [thewidgetsmith](https://github.com/thewidgetsmith)

## Acknowledgments

* The Coder developers for making a remote development platform that works
