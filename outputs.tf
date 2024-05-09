output "http_url" {
  value = format("http://localhost%s/", var.http_port == 80 ? "" : format(":%d", var.http_port))
}

output "https_url" {
  value = format("https://localhost%s/", var.https_port == 443 ? "" : format(":%d", var.https_port))
}
