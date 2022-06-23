#Creating Storage account

resource "google_storage_bucket" "bucket" {
  name     = var.bucket_name
  location = "US"
}

resource "google_storage_bucket_object" "archive" {
  name   = "index.zip"
  bucket = var.bucket_name
  source = "function.zip"
}
