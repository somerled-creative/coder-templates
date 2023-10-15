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

locals {
  username = data.coder_workspace.me.owner
}

data "coder_provisioner" "me" {
}

provider "docker" {
}

data "coder_workspace" "me" {
}

data "coder_parameter" "git_user_email" {
  default      = "${data.coder_workspace.me.owner_email}"
  display_name = "Git User Email"
  name         = "git_user_email"
  type         = "string"
  mutable      = true

  description  = <<-EOF
  The email address used for as `user.email` git config (optional).

  Defaults to the coder user email address.
  EOF
}

data "coder_parameter" "git_user_name" {
  default      = "${data.coder_workspace.me.owner}"
  display_name = "Git User Name"
  name         = "git_user_name"
  type         = "string"
  mutable      = true

  description  = <<-EOF
  The email address used for as `user.name` git config (optional).

  Defaults to the coder user name.
  EOF
}

resource "coder_agent" "main" {
  arch                   = data.coder_provisioner.me.arch
  os                     = "linux"
  startup_script_timeout = 180
  startup_script         = <<-EOT
    set -e

    # install and start code-server
    curl -fsSL https://code-server.dev/install.sh | sh -s -- --method=standalone --prefix=/tmp/code-server --version 4.11.0
    /tmp/code-server/bin/code-server --auth none --port 13337 >/tmp/code-server.log 2>&1 &

    # install OMZSH
    if [ ! -d "/home/${local.username}/.oh-my-zsh" ]; then
      curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh
    fi
  EOT

  # These environment variables allow you to make Git commits right away after creating a
  # workspace. Note that they take precedence over configuration defined in ~/.gitconfig!
  # You can remove this block if you'd prefer to configure Git manually or using
  # dotfiles. (see docs/dotfiles.md)
  env = {
    GIT_AUTHOR_NAME     = "${data.coder_parameter.git_user_name.value}"
    GIT_COMMITTER_NAME  = "${data.coder_parameter.git_user_name.value}"
    GIT_AUTHOR_EMAIL    = "${data.coder_parameter.git_user_email.value}"
    GIT_COMMITTER_EMAIL = "${data.coder_parameter.git_user_email.value}"
  }

  # The following metadata blocks are optional. They are used to display
  # information about your workspace in the dashboard. You can remove them
  # if you don't want to display any information.
  # For basic resources, you can use the `coder stat` command.
  # If you need more control, you can write your own script.
  metadata {
    display_name = "CPU Usage"
    key          = "0_cpu_usage"
    script       = "coder stat cpu"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "RAM Usage"
    key          = "1_ram_usage"
    script       = "coder stat mem"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "Home Disk"
    key          = "3_home_disk"
    script       = "coder stat disk --path $${HOME}"
    interval     = 60
    timeout      = 1
  }

  metadata {
    display_name = "CPU Usage (Host)"
    key          = "4_cpu_usage_host"
    script       = "coder stat cpu --host"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "Memory Usage (Host)"
    key          = "5_mem_usage_host"
    script       = "coder stat mem --host"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "Load Average (Host)"
    key          = "6_load_host"
    # get load avg scaled by number of cores
    script   = <<EOT
      echo "`cat /proc/loadavg | awk '{ print $1 }'` `nproc`" | awk '{ printf "%0.2f", $1/$2 }'
    EOT
    interval = 60
    timeout  = 1
  }

  metadata {
    display_name = "Swap Usage (Host)"
    key          = "7_swap_host"
    script       = <<EOT
      free -b | awk '/^Swap/ { printf("%.1f/%.1f", $3/1024.0/1024.0/1024.0, $2/1024.0/1024.0/1024.0) }'
    EOT
    interval     = 10
    timeout      = 1
  }
}

resource "coder_app" "code-server" {
  agent_id      = coder_agent.main.id
  display_name  = "code-server"
  icon          = "/icon/code.svg"
  share         = "owner"
  slug          = "code-server"
  subdomain     = false
  url           = "http://localhost:13337?folder=/home/${local.username}"

  healthcheck {
    interval  = 5
    threshold = 6
    url       = "http://localhost:13337/healthz"
  }
}

resource "docker_volume" "home_volume" {
  name = "vol-${data.coder_workspace.me.id}-home"
  # Protect the volume from being deleted due to changes in attributes.
  lifecycle {
    ignore_changes = all
  }
  # Add labels in Docker to keep track of orphan resources.
  labels {
    label = "coder.owner"
    value = data.coder_workspace.me.owner
  }
  labels {
    label = "coder.owner_id"
    value = data.coder_workspace.me.owner_id
  }
  labels {
    label = "coder.workspace_id"
    value = data.coder_workspace.me.id
  }
  # This field becomes outdated if the workspace is renamed but can
  # be useful for debugging or cleaning out dangling volumes.
  labels {
    label = "coder.workspace_name_at_creation"
    value = data.coder_workspace.me.name
  }
}

resource "docker_image" "main" {
  name = "coder-${data.coder_workspace.me.id}"
  build {
    context    = "./build"
    build_args = {
      USERNAME = local.username
    }
  }
  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset(path.module, "build/*") : filesha1(f)]))
  }
}

resource "docker_container" "dind" {
  count        = data.coder_workspace.me.start_count
  entrypoint   = ["dockerd", "-H", "tcp://0.0.0.0:2375"]
  image        = "docker:dind"
  name         = "dind-${data.coder_workspace.me.id}"
  network_mode = "host"
  privileged   = true
}

resource "docker_container" "workspace" {
  command      = ["sh", "-c", coder_agent.main.init_script]
  count        = data.coder_workspace.me.start_count
  hostname     = data.coder_workspace.me.name
  image        = docker_image.main.name
  name         = "work-${data.coder_workspace.me.id}"
  network_mode = "host"

  env = [
    "CODER_AGENT_TOKEN=${coder_agent.main.token}",
    "DOCKER_HOST=localhost:2375"
  ]

  volumes {
    container_path = "/home/${local.username}/"
    read_only      = false
    volume_name    = docker_volume.home_volume.name
  }

  # Add labels in Docker to keep track of orphan resources.
  labels {
    label = "coder.owner"
    value = data.coder_workspace.me.owner
  }
  labels {
    label = "coder.owner_id"
    value = data.coder_workspace.me.owner_id
  }
  labels {
    label = "coder.workspace_id"
    value = data.coder_workspace.me.id
  }
  labels {
    label = "coder.workspace_name"
    value = data.coder_workspace.me.name
  }
}

resource "coder_metadata" "workspace_info" {
  count       = data.coder_workspace.me.start_count
  resource_id = docker_container.workspace[0].id
  item {
    key   = "Docker host name"
    value = docker_container.dind[0].name
  }
}
