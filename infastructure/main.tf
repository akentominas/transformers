resource "null_resource" "check_env_vars" {
  provisioner "local-exec" {
    command = "python3 support-files/env.py"
  }
}
