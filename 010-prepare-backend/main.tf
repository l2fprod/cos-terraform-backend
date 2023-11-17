variable "ibmcloud_api_key" {
  type = string
}

variable "ibmcloud_timeout" {
  type    = number
  default = 600
}

variable "region" {
  type    = string
  default = "us-south"
}

variable "basename" {
  type = string
  default = "cos-terraform-backend"
}

variable "resource_group" {
  type    = string
  default = ""
}

variable "tags" {
  type    = list(string)
  default = ["terraform", "tutorial"]
}

terraform {
  required_version = "< 1.6.0"
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
}

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
  ibmcloud_timeout = var.ibmcloud_timeout
}

# a new or existing resource group to create resources
resource "ibm_resource_group" "group" {
  count = var.resource_group != "" ? 0 : 1
  name  = "${var.basename}-group"
  tags  = var.tags
}

data "ibm_resource_group" "group" {
  count = var.resource_group != "" ? 1 : 0
  name  = var.resource_group
}

locals {
  resource_group_id       = var.resource_group != "" ? data.ibm_resource_group.group.0.id : ibm_resource_group.group.0.id
}

# a COS instance
resource "ibm_resource_instance" "cos" {
  name              = "${var.basename}-cos"
  resource_group_id = local.resource_group_id
  service           = "cloud-object-storage"
  plan              = "standard"
  location          = "global"
  tags              = concat(var.tags, ["service"])
}

resource "ibm_resource_key" "cos_key" {
  name                 = "${var.basename}-cos-key"
  resource_instance_id = ibm_resource_instance.cos.id
  role                 = "Writer"

  parameters = {
    HMAC = true
  }
}

# a bucket
resource "ibm_cos_bucket" "bucket" {
  bucket_name          = "${var.basename}-bucket"
  resource_instance_id = ibm_resource_instance.cos.id
  region_location      = var.region
  storage_class        = "smart"
}

resource "local_file" "backend" {
  content = templatefile("../020-use-backend/backend.tf.tmpl",
    {
      bucket = ibm_cos_bucket.bucket.bucket_name
      endpoint = ibm_cos_bucket.bucket.s3_endpoint_public
      access_key = ibm_resource_key.cos_key.credentials["cos_hmac_keys.access_key_id"]
      secret_key = ibm_resource_key.cos_key.credentials["cos_hmac_keys.secret_access_key"]
      region = var.region
    }
  )
  filename = "../020-use-backend/backend.tf"
}
