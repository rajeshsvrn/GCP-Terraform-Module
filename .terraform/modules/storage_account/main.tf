provider "google" {
  credentials = "${file("C:\\Users\\Anonymous\\Downloads\\halogen-data-344904-eafc7577e57e.json")}"
  project     = var.project_id
  region      = var.region
  zone        = "us-central1-c"
}
provider "google-beta" {
  credentials = "${file("C:\\Users\\Anonymous\\Downloads\\halogen-data-344904-eafc7577e57e.json")}"
  project     = var.project_id
  region      = "us-central1"
  zone        = "us-central1-c"
}


module "vpc" {
  source                                 = "C:\\Users\\Anonymous\\Desktop\\GCP-Terraform-Module\\modules\\vpc"
  network_name                           = var.network_name
  auto_create_subnetworks                = var.auto_create_subnetworks
  routing_mode                           = var.routing_mode
  project_id                             = var.project_id


}

module "load_balancer"{
  
  source                                 = "C:\\Users\\Anonymous\\Desktop\\GCP-Terraform-Module\\modules\\load_balancer"
  network_id = module.vpc.network_id
  subnet_id = module.vpc.subnet_id
  global_address = module.vpc.global_address

}

module "storage_account" {

    source                                 = "C:\\Users\\Anonymous\\Desktop\\GCP-Terraform-Module\\modules\\storage_account"
    bucket_name = var.bucket_name
}

module "cloud_function" {
  source                                 = "C:\\Users\\Anonymous\\Desktop\\GCP-Terraform-Module\\modules\\cloud_function"
  
  bucket_id = module.storage_account.bucket_id
  object_id = module.storage_account.object_id
}

