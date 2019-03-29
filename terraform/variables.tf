variable "instance_name" {
  default     = "webslab"
}

variable "cluster1_name" {
  default     = "nginx-cluster1"
}

variable "cluster2_name" {
  default     = "nginx-cluster2"
}

variable "image_id" {
  default     = "webslab-base"
}

variable "machine_type" {
  default     = "n1-standard-1"
}

variable "total_nodes" {
  default     = "2"
}

variable "region1" {
  default     = "us-east4"
}

variable "zone1a" {
  default     = "us-east4-a"
}

variable "zone1b" {
  default     = "us-east4-b"
}

variable "region2" {
  default     = "europe-west1"
}

variable "zone2a" {
  default     = "europe-west1-b"
}

variable "zone2b" {
  default     = "europe-west1-d"
}
