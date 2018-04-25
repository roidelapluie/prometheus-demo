resource "digitalocean_ssh_key" "tf" {
  name       = "Terraform"
  public_key = "${file("id_rsa.pub")}"
}
