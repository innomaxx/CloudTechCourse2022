
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.16.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_image" "app" {
  name = "cloudtech52/demo:app"
}

resource "docker_image" "db" {
  name = "cloudtech52/demo:db"
}

resource "docker_network" "demo-net" {
  name = "demo-net"
}

resource "docker_container" "app" {
  image = docker_image.app.latest
  name  = "app"

  ports {
    internal = 5500
    external = 8500
  }

  networks_advanced {
    name = docker_network.demo-net.name
  }

  env = ["DB_HOST=db,1433", "DB_NAME=NetChatApp", "DB_USER=chatadmin", "DB_PASS=ChatPass34!", "ASPNETCORE_ENVIRONMENT=Production", "ASPNETCORE_HOSTINGSTARTUPASSEMBLIES=Microsoft.AspNetCore.Mvc.Razor.RuntimeCompilation", "ASPNETCORE_URLS=http://0.0.0.0:5500"]

  depends_on = [docker_network.demo-net, docker_container.mssql]
}

resource "docker_volume" "mssql-data" {
  name = "mssql-data"
}

resource "docker_container" "mssql" {
  image      = docker_image.db.latest
  name       = "mssql"

  networks_advanced {
    name = docker_network.demo-net.name
  }

  env = ["ACCEPT_EULA=Y", "MSSQL_SA_PASSWORD=(@MyVery.StrongPass@).2400", "MSSQL_DB=NetChatApp", "MSSQL_DB_USER=chatadmin", "MSSQL_DB_PASS=ChatPass34!"]

  volumes {
    container_path = "/var/opt/mssql/data"
    volume_name = docker_volume.mssql-data.name
  }

  depends_on = [docker_network.demo-net, docker_volume.mssql-data]
}