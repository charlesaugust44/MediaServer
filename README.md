# Media Server Stack

Self-hosted media server running on Docker Compose with Jellyfin, Jackett, Sonarr, Radarr, and qBittorrent.

## Services

| Service      | URL                       | Default User | Default Password |
|--------------|---------------------------|--------------|------------------|
| Jellyfin     | `http://localhost:8096`   | `admin`      | `123456`         |
| Jackett      | `http://localhost:9116`   | *(none)*     | `123456`         |
| Sonarr       | `http://localhost:8986`   | `admin`      | `123456`         |
| Radarr       | `http://localhost:7876`   | `admin`      | `123456`         |
| qBittorrent  | `http://localhost:8085`   | `admin`      | `123456`         |

> ⚠ **Change all default passwords immediately after first login.**

## Prerequisites

- [Docker](https://docs.docker.com/engine/install/) and [Docker Compose](https://docs.docker.com/compose/install/)
- `openssl` (usually pre-installed on Linux/macOS)

## Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/your-username/media-server.git
cd media-server

# 2. Make scripts executable
chmod +x setup.sh

# 3. Run the setup (creates folders, handles SSL cert, starts containers)
./setup.sh