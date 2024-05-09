terraform {
    required_providers {
        docker = {
            source = "kreuzwerker/docker"
            version = "~>3.0.1"
        }
        random = {
            source = "hashicorp/random"
            version = "~>3.6.1"
        }
        http = {
            source = "hashicorp/http"
            version = "~>3.4.2"
        }
        time = {
            source = "hashicorp/time"
            version = "0.11.1"
        }
    }
}

provider "docker" {}

provider "random" {}

provider "http" {}
