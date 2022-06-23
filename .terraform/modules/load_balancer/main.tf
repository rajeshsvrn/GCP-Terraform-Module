resource "google_compute_global_forwarding_rule" "default" {
  name                  = "tcp-proxy-xlb-forwarding-rule"
  provider              = google-beta
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "110"
  target                = google_compute_target_tcp_proxy.default.id
  ip_address            = var.global_address
}

resource "google_compute_target_tcp_proxy" "default" {
  provider = google-beta
  name            = "test-proxy-health-check"
  backend_service = google_compute_backend_service.default.id
}

# backend service
resource "google_compute_backend_service" "default" {
  provider = google-beta
  name                  = "tcp-proxy-xlb-backend-service"
  protocol              = "TCP"
  port_name             = "tcp"
  load_balancing_scheme = "EXTERNAL"
  timeout_sec           = 10
  health_checks         = [google_compute_health_check.default.id]
  backend {
    group           = google_compute_instance_group_manager.default.instance_group
    balancing_mode  = "UTILIZATION"
    max_utilization = 1.0
    capacity_scaler = 1.0
  }
}

resource "google_compute_health_check" "default" {
  provider = google-beta
  name               = "tcp-proxy-health-check"
  timeout_sec        = 1
  check_interval_sec = 1

  tcp_health_check {
    port = "80"
  }
}

# instance template
resource "google_compute_instance_template" "default" {
  name         = "tcp-proxy-xlb-mig-template"
  provider     = google-beta
  machine_type = "e2-small"
  tags         = ["allow-health-check"]

  network_interface {
    network    = var.network_id
    subnetwork = var.subnet_id
    access_config {
      # add external ip to fetch packages
    }
  }
  disk {
    source_image = "debian-cloud/debian-10"
    auto_delete  = true
    boot         = true
  }

  # install nginx and serve a simple web page
  metadata = {
    startup-script = <<-EOF1
      #! /bin/bash
      set -euo pipefail
      export DEBIAN_FRONTEND=noninteractive
      apt-get update
      apt-get install -y nginx-light jq
      NAME=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/hostname")
      IP=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip")
      METADATA=$(curl -f -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/?recursive=True" | jq 'del(.["startup-script"])')
      cat <<EOF > /var/www/html/index.html
      <pre>
      Name: $NAME
      IP: $IP
      Metadata: $METADATA
      </pre>
      EOF
    EOF1
  }
  lifecycle {
    create_before_destroy = true
  }
}

# MIG
resource "google_compute_instance_group_manager" "default" {
  name     = "tcp-proxy-xlb-mig1"
  provider = google-beta
  zone     = "us-central1-c"
  named_port {
    name = "tcp"
    port = 110
  }
  version {
    instance_template = google_compute_instance_template.default.id
    name              = "primary"
  }
  base_instance_name = "vm"
  target_size        = 2
}

# allow access from health check ranges
resource "google_compute_firewall" "default" {
  name          = "tcp-proxy-xlb-fw-allow-hc"
  provider      = google-beta
  direction     = "INGRESS"
  network       = var.network_id
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  allow {
    protocol = "tcp"
  }
  target_tags = ["allow-health-check"]
}
