#Creating Storage account

output "bucket_id" {
  value = google_storage_bucket.bucket.name
  description = "Bucket name"
}

output "object_id" {
  value = google_storage_bucket_object.archive.name
  description = "object name"
 
  
}
