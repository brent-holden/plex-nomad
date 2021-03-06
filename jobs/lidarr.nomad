job "lidarr" {
  datacenters = ["lab"]
  type = "service"

  constraint {
    attribute = "${meta.media_node}"
    value     = "true"
  }

  group "lidarr" {
    count = 1

    network {
      mode  = "bridge"
      port "lidarr" { to = 8686 }
    }

    update {
      max_parallel  = 0
      health_check  = "checks"
      auto_revert   = true
    }

    task "lidarr" {
      driver = "containerd-driver"

      service {
        name = "lidarr"
        port = "lidarr"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.lidarr.rule=Host(`${ACME_HOST}`) && PathPrefix(`/lidarr`)",
        ]

        check {
          type      = "http"
          port      = "lidarr"
          path      = "/lidarr/login/"
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
        image         = "docker.io/linuxserver/lidarr:${RELEASE}"
        mounts  = [
                    {
                      type    = "bind"
                      target  = "/config"
                      source  = "/opt/lidarr"
                      options = ["rbind", "rw"]
                    },
                    {
                      type    = "bind"
                      target  = "/downloads"
                      source  = "/mnt/downloads"
                      options = ["rbind", "rw"]
                    },
                    {
                      type    = "bind"
                      target  = "/music"
                      source  = "/mnt/rclone/media/Music"
                      options = ["rbind", "rw"]
                    }
                  ]
      }

      template {
        data          = <<EOH
IMAGE_DIGEST={{ keyOrDefault "lidarr/config/image_digest" "1" }}
RELEASE={{ keyOrDefault "lidarr/config/release" "latest" }}
ACME_HOST={{ key "traefik/config/acme_host" }}
EOH
        destination   = "env_info"
        env           = true
      }

      resources {
        cpu    = 500
        memory = 2048
      }

      kill_timeout = "20s"
    }
  }
}
