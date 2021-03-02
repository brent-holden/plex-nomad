job "hydra2" {
  datacenters = ["lab"]
  type = "service"

  constraint {
    attribute = "${meta.media_node}"
    value     = "true"
  }

  update {
    max_parallel  = 0
    health_check  = "checks"
    auto_revert   = true
  }

  group "hydra2" {
    count = 1

    network {
      mode = "bridge"
      port "hydra2" { static = 5076 }
    }

    task "hydra2" {
      driver = "containerd-driver"

      service {
        name = "hydra2"
        port = "hydra2"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.hydra2.rule=PathPrefix(`/hydra2`)",
          "traefik.http.routers.hydra2.entrypoints=http",
          "traefik.http.services.hydra2.loadbalancer.server.port=${NOMAD_HOST_PORT_hydra2}",
        ]

        check {
          type      = "http"
          port      = "hydra2"
          path      = "/hydra2/login.html"
          interval  = "30s"
          timeout   = "2s"

          check_restart {
            limit = 10000
            grace = "60s"
          }
        }
      }

      restart {
        interval  = "12h"
        attempts  = 720
        delay     = "60s"
        mode      = "delay"
      }

      env {
       PGID = "1100"
       PUID = "1100"
      }

      config {
        image   = "docker.io/linuxserver/nzbhydra2:${RELEASE}"
        mounts  = [
                    {
                      type    = "bind"
                      target  = "/config"
                      source  = "/opt/hydra2"
                      options = ["rbind", "rw"]
                    },
                    {
                      type    = "bind"
                      target  = "/downloads"
                      source  = "/mnt/downloads"
                      options = ["rbind", "rw"]
                    }
                  ]
      }

      template {
        data          = <<EOH
IMAGE_ID={{ keyOrDefault "hydra2/config/image_id" "1" }}
RELEASE={{ keyOrDefault "hydra2/config/release" "latest" }}
EOH
        destination   = "env_info"
        env           = true
      }

      resources {
        cpu    = 1000
        memory = 2048
      }

      kill_timeout = "20s"
    }
  }
}
