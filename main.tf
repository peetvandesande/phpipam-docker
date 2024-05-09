data "http" "phpipam-sql" {
    #url = "https://raw.githubusercontent.com/phpipam/phpipam/1.6/db/SCHEMA.sql"
    url = "https://raw.githubusercontent.com/phpipam/phpipam/master/db/SCHEMA.sql"
}

resource "local_sensitive_file" "phpipam-sql" {
    content = data.http.phpipam-sql.response_body
    filename = "${path.cwd}/dbinit/phpipam.sql"
    file_permission = "0644"
}

resource "random_password" "db_root_pass" {
    length = 16
    special = true
}

resource "random_password" "db_ipam_pass" {
    length = 16
    special = true
}

data "docker_registry_image" "phpipam-web" {
    #name = "phpipam/phpipam-www:1.6x"
    name = "phpipam/phpipam-www:nightly"
}

resource "docker_image" "phpipam-web" {
    name = data.docker_registry_image.phpipam-web.name
    pull_triggers = [data.docker_registry_image.phpipam-web.sha256_digest]
    keep_locally = false
}

data "docker_registry_image" "mariadb" {
    name = "mariadb"
}

resource "docker_image" "mariadb" {
    name = data.docker_registry_image.mariadb.name
    pull_triggers = [data.docker_registry_image.mariadb.sha256_digest]
    keep_locally = false
}

resource "docker_network" "phpipam" {
    name = "ipamnet"
    driver = "bridge"
}

resource "docker_container" "db" {
    name = "mariadb"
    image = docker_image.mariadb.image_id
    must_run = true
    restart = "unless-stopped"

    networks_advanced {
        name = docker_network.phpipam.name
        aliases = ["ipamnet"]
    }

    env = [
        format("MYSQL_ROOT_PASSWORD=%s", random_password.db_root_pass.result),
        format("MARIADB_USER=%s", var.ipam_db_user),
        format("MARIADB_PASSWORD=%s", random_password.db_ipam_pass.result),
        format("MARIADB_DATABASE=%s", var.ipam_db_name)
    ]

    volumes {
        volume_name = "mariadb-data"
        container_path = "/var/lib/mysql"
    }

    mounts {
        target = "/docker-entrypoint-initdb.d"
        type = "bind"
        source = "${path.cwd}/dbinit"
    }

    depends_on = [
        local_sensitive_file.phpipam-sql,
        random_password.db_root_pass,
        random_password.db_ipam_pass
    ]
}

resource "time_sleep" "wait" {
    depends_on = [docker_container.db]
    create_duration = "15s"
}

resource "docker_container" "app-web" {
    name = "phpipam-web"
    image = docker_image.phpipam-web.image_id
    must_run = true
    restart = "unless-stopped"

    networks_advanced {
        name = docker_network.phpipam.name
        aliases = ["ipamnet"]
    }

    ports {
        internal = 80
        external = var.http_port
    }

    ports {
        internal = 443
        external = var.https_port
    }

    env = [
        "TZ=Europe/London",
        format("IPAM_DATABASE_HOST=%s", docker_container.db.name),
        format("IPAM_DATABASE_USER=%s", var.ipam_db_user),
        format("IPAM_DATABASE_PASS=%s", random_password.db_ipam_pass.result),
        format("IPAM_DATABASE_NAME=%s", var.ipam_db_name),
        "IPAM_DATABASE_WEBHOST=%"
    ]

    volumes {
        volume_name = "phpipam-logo"
        container_path = "/phpipam/css/images/logo"
    }

    volumes {
        volume_name = "phpipam-ca"
        container_path = "/usr/local/share/ca-certificates"
        read_only = true
    }

    depends_on = [
        time_sleep.wait
    ]
}

resource "docker_volume" "phpipam-logo" {
    name = "phpipam-logo"
}

resource "docker_volume" "phpipam-ca" {
    name = "phpipam-ca"
}

resource "docker_volume" "mariadb-data" {
    name = "mariadb-data"
}
