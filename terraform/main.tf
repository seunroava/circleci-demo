terraform {
  required_version = ">= 0.12.0"

  backend "gcs" {
    bucket      = "roava-io-terraform"
    prefix      = "terraform-circleci/state"
    #credentials = file("gcp_account.json")
  }
}

provider "google" {
  credentials = file("gcp_account.json")
  project     = "roava-io"
  region      = "us-central1"
}

resource "google_container_cluster" "gke-cluster" {
  name                     = "demo"
  location                 = "us-central1"
  remove_default_node_pool = true

  # In regional cluster (location is region, not zone) 
  # this is a number of nodes per zone 
  initial_node_count = 1
}

resource "google_container_node_pool" "preemptible_node_pool" {
  name     = "default-pool"
  location = "us-central1"

  cluster  = google_container_cluster.gke-cluster.name
  # In regional cluster (location is region, not zone) 

  node_count = 1
  node_config {
    preemptible  = true
    machine_type = "n1-standard-1"

    oauth_scopes = [
      "storage-ro",
      "logging-write",
      "monitoring",
    ]
  }
}
