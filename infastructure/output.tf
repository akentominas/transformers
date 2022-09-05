output "private_key" {
  value     = tls_private_key.transifex.private_key_pem
  sensitive = true
}
