#1 - instance group, 2 - health check, 3 - backend service, 4 - add instance group to backend service,
#5 - create url map, 6 - create http proxy, 7 - reserve global ip, 8 - create global forwarding rules

#global forward rules to route incoming requests to the proxy
resource "google_compute_global_forwarding_rule" "default" {
  name   = "webslab-forwarding-rule"
  target = "${google_compute_target_http_proxy.default.self_link}"
  port_range = "80"
  ip_address = "${google_compute_global_address.default.address}"
}

#reserve a public static ip
resource "google_compute_global_address" "default" {
  name = "global-address"
}

#proxy to route requests to url map
resource "google_compute_target_http_proxy" "default" {
  name        = "http-proxy"
  url_map     = "${google_compute_url_map.default.self_link}"
}

#url map to direct incoming requests to all instances
resource "google_compute_url_map" "default" {
  name        = "url-map"
  default_service = "${google_compute_backend_service.default.self_link}"
}

#backend service for load balancing
resource "google_compute_backend_service" "default" {
  name             = "backend-service"
  protocol         = "HTTP"
  timeout_sec      = 10

  backend {
    group = "${google_compute_region_instance_group_manager.img1.instance_group}"
  }
  
  backend{
    group = "${google_compute_region_instance_group_manager.img2.instance_group}"
  }

  health_checks = ["${google_compute_health_check.default.self_link}"]
}

#health check for crashed vms
resource "google_compute_health_check" "default" {
  name               = "health-check"
  check_interval_sec = 1
  timeout_sec        = 1

  tcp_health_check {
    port = "80"
  }
}

#instance template
resource "google_compute_instance_template" "default" {
  name = "webslab-instance-template"
  machine_type = "${var.machine_type}"

  # boot disk specifications
  disk {
    auto_delete  = true
    boot         = true
    source_image = "${var.image_id}"
    type         = "PERSISTENT"
    disk_type    = "pd-ssd"
  }

  # networks to attach to the VM
  network_interface {
    network = "default"
    access_config {} // use ephemeral public IP
  }
}

#instance group manager 1
resource "google_compute_region_instance_group_manager" "img1" {
  base_instance_name = "${var.instance_name}"
  instance_template  = "${google_compute_instance_template.default.self_link}"
  region             = "${var.region1}"
  distribution_policy_zones  = ["${var.zone1a}", "${var.zone1b}"]
  target_size        = "${var.total_nodes}"
  name               = "${var.cluster1_name}"
}

#instance group manager 2
resource "google_compute_region_instance_group_manager" "img2" {
  base_instance_name = "${var.instance_name}"
  instance_template  = "${google_compute_instance_template.default.self_link}"
  region             = "${var.region2}"
  distribution_policy_zones  = ["${var.zone2a}", "${var.zone2b}"]
  target_size        = "${var.total_nodes}"
  name               = "${var.cluster2_name}"
}

#ssh keys for auth
resource "google_compute_project_metadata" "default" {
  metadata {
    ssh-keys = "webslab-user:${file("~/.ssh/webslab-user.pub")}" // path to ssh key file
  }
}

#gc firewall rule on port 80
resource "google_compute_firewall" "default" {
  name    = "allow-webslab-tcp-80"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["0.0.0.0/0"]
}
