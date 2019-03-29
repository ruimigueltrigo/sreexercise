output "webslab_public_ip" {
  value = "${google_compute_global_address.default.address}"
}
