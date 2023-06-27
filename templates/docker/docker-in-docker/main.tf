terraform {
  required_providers {
    coder = {
      source  = "coder/coder"
    }
    docker = {
      source  = "kreuzwerker/docker"
    }
  }
}

provider "docker" {
}

data "coder_workspace" "me" {}

variable "dotfiles_uri" {
  description = <<-EOF
  Dotfiles repo URI (optional)

  see https://dotfiles.github.io
  EOF
  default = "git@github.com:sharkymark/dotfiles.git"
}

resource "coder_agent" "coder" {
  os   = "linux"
  arch = "amd64"
  dir = "/home/coder"
  startup_script = <<EOT
#!/bin/bash

# clone coder/coder repo
mkdir -p ~/.ssh
ssh-keyscan -t ed25519 github.com >> ~/.ssh/known_hosts
git clone --progress git@github.com:sharkymark/flask-redis-docker-compose.git &

# use coder CLI to clone and install dotfiles
coder dotfiles -y ${var.dotfiles_uri} &

# install and start code-server
curl -fsSL https://code-server.dev/install.sh | sh
code-server --auth none --port 13337 &

  EOT
}

# code-server
resource "coder_app" "code-server" {
  agent_id      = coder_agent.coder.id
  slug          = "code-server"
  display_name  = "VS Code"
  icon          = "/icon/code.svg"
  url           = "http://localhost:13337?folder=/home/coder"
  subdomain = false
  share     = "owner"

  healthcheck {
    url       = "http://localhost:13337/healthz"
    interval  = 3
    threshold = 10
  }
}

resource "docker_network" "private_network" {
  name = "network-${data.coder_workspace.me.id}"
}

resource "docker_container" "dind" {
  count   = data.coder_workspace.me.start_count
  image      = "docker:dind"
  privileged = true
  name       = "dind-${data.coder_workspace.me.id}"
  entrypoint = ["dockerd", "-H", "tcp://0.0.0.0:2375"]
  networks_advanced {
    name = docker_network.private_network.name
  }
}

resource "docker_container" "workspace" {
  count   = data.coder_workspace.me.start_count
  image   = "codercom/enterprise-base:ubuntu"
  name    = "dev-${data.coder_workspace.me.id}"
  command = ["sh", "-c", coder_agent.coder.init_script]
  env = [
    "CODER_AGENT_TOKEN=${coder_agent.coder.token}",
    "DOCKER_HOST=${docker_container.dind[0].name}:2375"
  ]
  volumes {
    container_path = "/home/coder/"
    volume_name    = docker_volume.coder_volume.name
    read_only      = false
  }
  networks_advanced {
    name = docker_network.private_network.name
  }
}

resource "docker_volume" "coder_volume" {
  name = "coder-${data.coder_workspace.me.owner}-${data.coder_workspace.me.name}"
}

resource "coder_metadata" "workspace_info" {
  count       = data.coder_workspace.me.start_count
  resource_id = docker_container.workspace[0].id
  item {
    key   = "Docker host name"
    value = docker_container.dind[0].name
  }
  item {
    key   = "Docker network name"
    value = docker_network.private_network.name
  }
  item {
    key   = "image"
    value = "docker.io/codercom/enterprise-base:ubuntu"
  }
  item {
    key   = "repo cloned"
    value = "docker.io/sharkymark/flask-redis-docker-compose.git"
  }
}
