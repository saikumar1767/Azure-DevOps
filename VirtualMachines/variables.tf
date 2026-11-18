variable "location" {
  type = string
  default = "canadacentral"
}

variable "environments" {
  type = map(string)
  default = {
    "dev" = "Standard_B1s"
    "qa" = "Standard_B1s"
    "prod" = "Standard_B2s"
  }
}

variable "adminusername" {
  type = string
  default = "devopsuser"
}

variable "ssh_publickey_path" {
  type = string
  default = "C:/Users/user/.ssh/devopsuser_key.pub"
}




# ssh-keygen -t rsa -b 4096 -C "devopsuser" -f "$HOME\.ssh\devopsuser_key"
# Generating public/private rsa key pair.
# Enter passphrase (empty for no passphrase): 
# Enter same passphrase again: 
# "C:\Users\user\.ssh\devopsuser_key.pub"