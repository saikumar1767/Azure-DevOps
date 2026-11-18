# -------------------------
# Workspace
# -------------------------
# terraform.workspace = name of the selected workspace (dev / prod)

locals {
  env = terraform.workspace

  # Every resource name starts with this, e.g. "azdemo-dev"
  name_prefix = "${var.project}-${local.env}"

  tags = {
    project     = var.project
    environment = local.env
    managed_by  = "terraform"
  }
}
