resource "null_resource" "test" {
  provisioner "local-exec" {
      echo 'test'
  }
}
