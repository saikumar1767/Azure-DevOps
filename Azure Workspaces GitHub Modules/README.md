# Azure Workspaces + Modules from GitHub

Same project as [Azure Workspaces Demo](../Azure%20Workspaces%20Demo/README.md)
(4 modules, `dev` and `prod` workspaces), with one change: the modules are **not**
in a local `modules/` folder. Terraform downloads them from a GitHub repository.

This is how it is normally done in real projects:

```
 GitHub repo 1: terraform-azure-modules        GitHub repo 2 / this folder
 (owned by the platform team)                  (owned by the project team)
 ┌──────────────────────────────┐              ┌─────────────────────────────┐
 │ modules/resource-group       │   v1.0.0     │ main.tf  ── source = git::… │
 │ modules/network              │ ◄─────────── │ dev.tfvars / prod.tfvars    │
 │ modules/vm                   │  terraform   │ backend.tf, locals.tf …     │
 │ modules/storage              │     init     │ (no modules folder)         │
 └──────────────────────────────┘              └─────────────────────────────┘
```

- The **modules repo** holds reusable code. Every release gets a **git tag** (`v1.0.0`).
- The **project code** calls a module by its GitHub URL and **pins a tag**, so a
  change in the modules repo never reaches your environments until you choose it.

## What is in this folder

```
Azure Workspaces GitHub Modules/
├── backend.tf        remote state, new key (separate from yesterday's demo)
├── provider.tf       azurerm provider
├── locals.tf         workspace name -> name prefix + tags
├── main.tf           calls the 4 modules FROM GITHUB
├── variables.tf      inputs
├── outputs.tf        outputs
├── dev.tfvars        project = "azgh" (so names do not clash with "azdemo")
└── prod.tfvars
```

There is no `modules/` folder here. You create the modules repo in Part 1.

## Before you start

1. Terraform, Azure CLI and Git installed. `az login` done.
2. A GitHub account.
3. Access to the backend storage account `amazonsa198`.

---

## Part 1 - Create the modules repository on GitHub

### Step 1. Create an empty repo

On github.com: **New repository** -> name `terraform-azure-modules` -> **Public**
-> do **not** tick "Add a README" -> **Create repository**.

(Public keeps this exercise simple. Real companies use private repos, see
[Private repositories](#private-repositories).)

### Step 2. Copy yesterday's modules into a new local folder

Run this from the `Terraform` folder (the parent of this folder):

```powershell
New-Item -ItemType Directory C:\repos\terraform-azure-modules
Copy-Item -Recurse ".\Azure Workspaces Demo\modules" C:\repos\terraform-azure-modules\
cd C:\repos\terraform-azure-modules
```

You should now have:

```
C:\repos\terraform-azure-modules\
└── modules\
    ├── resource-group\   main.tf  variables.tf  outputs.tf
    ├── network\          main.tf  variables.tf  outputs.tf
    ├── vm\               main.tf  variables.tf  outputs.tf
    └── storage\          main.tf  variables.tf  outputs.tf
```

### Step 3. Push it to GitHub

Replace `YOUR_GITHUB_USER` with your GitHub username.

```powershell
git init -b main
git add .
git commit -m "Add resource-group, network, vm and storage modules"
git remote add origin https://github.com/YOUR_GITHUB_USER/terraform-azure-modules.git
git push -u origin main
```

The first push opens a browser window to sign in to GitHub.

### Step 4. Tag a release

```powershell
git tag -a v1.0.0 -m "First release"
git push origin v1.0.0
```

Check on GitHub: the repo shows the `modules` folder, and the branch dropdown
-> **Tags** shows `v1.0.0`.

---

## Part 2 - Use the modules from this folder

### Step 5. Put your username in main.tf

Open [main.tf](main.tf) and replace `YOUR_GITHUB_USER` in all 4 `source` lines.

```hcl
module "network" {
  source = "git::https://github.com/YOUR_GITHUB_USER/terraform-azure-modules.git//modules/network?ref=v1.0.0"
  ...
}
```

How to read the source line:

| Part | Meaning |
|---|---|
| `git::` | download with git |
| `https://github.com/.../terraform-azure-modules.git` | the repository |
| `//modules/network` | folder inside the repo (the double slash is required) |
| `?ref=v1.0.0` | tag to use (can also be a branch or a commit ID) |

Everything else in the module block (the inputs) is the same as yesterday.

### Step 6. Init

```powershell
cd "<path>\Terraform\Azure Workspaces GitHub Modules"

az login
$env:ARM_SUBSCRIPTION_ID   = (az account show --query id -o tsv)
$env:TF_VAR_admin_password = "<your password>"

terraform init
```

`init` now prints a download line for each module:

```
Initializing modules...
Downloading git::https://github.com/.../terraform-azure-modules.git?ref=v1.0.0 for network...
- network in .terraform\modules\network\modules\network
```

The downloaded copy is in `.terraform\modules\`. Never edit it there; changes
go into the modules repo.

### Step 7. Workspaces, plan, apply (same as yesterday)

```powershell
terraform workspace new dev
terraform plan  -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars"

terraform workspace new prod
terraform plan  -var-file="prod.tfvars"
terraform apply -var-file="prod.tfvars"
```

Rule from yesterday still applies: `dev` workspace -> `dev.tfvars`,
`prod` workspace -> `prod.tfvars`.

---

## Part 3 - Changing a module (the day-to-day flow)

Example: add a tag to every storage account.

**1. Change the module in the modules repo, on a branch**

```powershell
cd C:\repos\terraform-azure-modules
git checkout -b add-storage-tag
# edit modules\storage\main.tf
git add .
git commit -m "storage: add cost-center tag"
git push -u origin add-storage-tag
```

**2. Pull request** on GitHub -> review -> merge into `main`.

**3. Tag the new release**

```powershell
git checkout main
git pull
git tag -a v1.1.0 -m "storage: add cost-center tag"
git push origin v1.1.0
```

**4. Use the new version in the project**

In `main.tf` change the storage module from `?ref=v1.0.0` to `?ref=v1.1.0`, then:

```powershell
terraform init -upgrade                  # downloads v1.1.0

terraform workspace select dev
terraform plan  -var-file="dev.tfvars"   # check the change
terraform apply -var-file="dev.tfvars"

terraform workspace select prod          # only after dev looks good
terraform plan  -var-file="prod.tfvars"
terraform apply -var-file="prod.tfvars"
```

Until step 4, dev and prod stay on `v1.0.0` even though the modules repo changed.
That is the reason for pinning a tag.

### Version numbers

| Change | Example | New tag |
|---|---|---|
| Bug fix, nothing changes for callers | fix a typo in a tag | `v1.0.1` |
| New optional input or new output | add `sku` variable with a default | `v1.1.0` |
| Callers must change their code | rename or remove a variable | `v2.0.0` |

### Rules teams follow

- Always pin `?ref=` to a tag. Without `ref`, Terraform takes the latest `main`
  and every `init` can bring different code.
- Never move or delete a tag that was released. Make a new one.
- Workspaces share one `main.tf`, so dev and prod use the same module version.
  Apply in dev first, then prod.

---

## Part 4 - State file and dependency use cases

Do these after Step 7, in the **prod** workspace (it has 2 VMs and 2 storage
accounts, so there is something to remove).

```powershell
terraform workspace select prod
```

Resource addresses used below. The `[0]`, `[1]` come from `count` in the module.

| Address | Azure resource |
|---|---|
| `module.resource_group.azurerm_resource_group.main` | `azgh-prod-rg` |
| `module.network.azurerm_virtual_network.main` | VNet |
| `module.network.azurerm_subnet.main` | Subnet |
| `module.vm.azurerm_network_interface.main[0]` / `[1]` | NICs |
| `module.vm.azurerm_linux_virtual_machine.main[0]` / `[1]` | `azgh-prod-vm-1` / `-2` |
| `module.storage.azurerm_storage_account.main[0]` / `[1]` | `azghsaprod1` / `azghsaprod2` |

In PowerShell, put addresses with `[ ]` inside single quotes.

### Use case 1 - See what is in the state file

```powershell
terraform state list                       # every resource in this workspace
terraform state list module.vm             # only one module
terraform state list module.storage

terraform state show 'module.storage.azurerm_storage_account.main[0]'   # all attributes of one resource
terraform show                             # all attributes of everything
```

Expected `terraform state list` in prod (9 resources):

```
module.network.azurerm_subnet.main
module.network.azurerm_virtual_network.main
module.resource_group.azurerm_resource_group.main
module.storage.azurerm_storage_account.main[0]
module.storage.azurerm_storage_account.main[1]
module.vm.azurerm_linux_virtual_machine.main[0]
module.vm.azurerm_linux_virtual_machine.main[1]
module.vm.azurerm_network_interface.main[0]
module.vm.azurerm_network_interface.main[1]
```

Switch to `dev` and run it again: the list is shorter (6 resources). Same code,
different state file.

### Use case 2 - Back up the state before touching it

```powershell
terraform state pull | Out-File -Encoding utf8 prod-backup.tfstate
```

`state pull` downloads the raw state JSON from the backend. Always do this
before `state rm`, `state mv` or `import`. Delete the backup file when you are
done; it contains secrets (the VM password).

### Use case 3 - Remove a resource from the state, keep it in Azure

Real-life reason: another team takes over a storage account, or you want
Terraform to stop managing something without deleting it.

```powershell
terraform state rm -dry-run 'module.storage.azurerm_storage_account.main[1]'   # shows what would be removed
terraform state rm          'module.storage.azurerm_storage_account.main[1]'

terraform state list module.storage        # [1] is gone from the state
az storage account show -n azghsaprod2 -g azgh-prod-rg --query name -o tsv   # still exists in Azure
```

Now run a plan:

```powershell
terraform plan -var-file="prod.tfvars"     # Plan: 1 to add
```

Terraform wants to **create** `azghsaprod2` again, because the code still asks
for 2 storage accounts and the state only knows 1. Do **not** apply; it fails
with "already exists - needs to be imported".

### Use case 4 - Bring that resource back into the state (import)

```powershell
$id = az storage account show -n azghsaprod2 -g azgh-prod-rg --query id -o tsv

terraform import -var-file="prod.tfvars" 'module.storage.azurerm_storage_account.main[1]' $id

terraform plan -var-file="prod.tfvars"     # No changes
```

`state rm` and `import` are opposites: one makes Terraform forget a resource,
the other makes Terraform adopt an existing one.

### Use case 5 - Remove a whole module from the state

```powershell
terraform state rm -dry-run module.storage     # lists both storage accounts
```

Without `-dry-run` this removes every resource of the module from the state in
one command. Run it only as a dry run here, or import both accounts back
afterwards as in use case 4.

### Use case 6 - Really delete one resource in Azure

`state rm` never deletes anything in Azure. To delete the real resource:

```powershell
terraform destroy -var-file="prod.tfvars" -target='module.vm.azurerm_linux_virtual_machine.main[1]'
```

This deletes `azgh-prod-vm-2` only. Its NIC stays, because nothing was
targeted that the NIC depends on.

`-target` is for emergencies. The code still says `vm_count = 2`, so the next
`terraform apply -var-file="prod.tfvars"` creates the VM again. The normal way
to remove a resource for good is to change the code or tfvars
(`vm_count = 1`) and run `apply`.

| Command | State file | Azure |
|---|---|---|
| `terraform state rm <address>` | removed | **kept** |
| `terraform destroy -target=<address>` | removed | **deleted** |
| change code / tfvars, then `apply` | removed | **deleted** |
| `terraform import <address> <id>` | added | unchanged |

### Use case 7 - See the dependency graph

```powershell
terraform graph
```

The output is text in DOT format. Each `->` line means "left depends on right":

```
"module.network.azurerm_subnet.main"            -> "module.network.azurerm_virtual_network.main"
"module.network.azurerm_virtual_network.main"   -> "module.resource_group.azurerm_resource_group.main"
"module.storage.azurerm_storage_account.main"   -> "module.resource_group.azurerm_resource_group.main"
"module.vm.azurerm_linux_virtual_machine.main"  -> "module.vm.azurerm_network_interface.main"
"module.vm.azurerm_network_interface.main"      -> "module.network.azurerm_subnet.main"
```

Read as a tree (create order is top to bottom, destroy order is bottom to top):

```
resource group
├── virtual network
│   └── subnet
│       └── network interface
│           └── virtual machine
└── storage account
```

This explains use case 6: the VM is at the bottom of its branch, so deleting it
touches nothing else. Targeting the subnet would also delete the NICs and VMs.

**As a picture.** Install Graphviz once (`winget install Graphviz.Graphviz`,
then open a new terminal):

```powershell
terraform graph | Out-File -Encoding ascii graph.dot
dot -Tpng graph.dot -o graph.png
start graph.png
```

No Graphviz: open `graph.dot` in Notepad and paste the text into an online
Graphviz viewer.

**More detail.** The default graph shows resources only. To also see variables,
outputs, locals and the provider:

```powershell
terraform graph -type=plan | Out-File -Encoding ascii graph-full.dot
```

### Use case 8 - See dependencies recorded in the state file

The state file stores, for every resource, what it depended on when it was
created. Terraform uses this to destroy in the right order.

```powershell
$state = terraform state pull | Out-String | ConvertFrom-Json

foreach ($r in $state.resources) {
  "$($r.module).$($r.type).$($r.name)"
  $r.instances[0].dependencies | Where-Object { $_ } | ForEach-Object { "    depends on  $_" }
}
```

A resource with no "depends on" lines (the resource group) is the root of the tree.

---

## Private repositories

The `source` line stays the same. Only the login changes.

| Where | How Terraform logs in to GitHub |
|---|---|
| Your laptop, HTTPS | Git Credential Manager (the browser sign-in from the first `git push`) |
| Your laptop, SSH | `source = "git::ssh://git@github.com/ORG/terraform-azure-modules.git//modules/network?ref=v1.0.0"` |
| Pipeline (Azure DevOps, GitHub Actions) | A token stored as a pipeline secret, set before `terraform init` (below) |

```powershell
git config --global url."https://oauth2:$($env:GITHUB_TOKEN)@github.com/".insteadOf "https://github.com/"
```

## Troubleshooting

| Error | Cause |
|---|---|
| `Could not download module ... repository not found` | Wrong username in `source`, or the repo is private and you are not logged in |
| `couldn't find remote ref v1.0.0` | Tag not pushed. Run `git push origin v1.0.0` |
| `Unreadable module directory` / `subdir "modules/network" not found` | Folder name in `//modules/...` does not match the repo |
| `Module not installed` or `Module source has changed` | Run `terraform init` (or `terraform init -upgrade` after changing `ref`) |
| `git must be available and on the PATH` | Install Git, open a new terminal |

## Cleanup

```powershell
terraform workspace select dev
terraform destroy -var-file="dev.tfvars"
terraform workspace select prod
terraform destroy -var-file="prod.tfvars"
terraform workspace select default
terraform workspace delete dev
terraform workspace delete prod
```
