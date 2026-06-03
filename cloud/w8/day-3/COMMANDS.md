# W8-D3 Commands

Run from the repo root unless a specific path is shown.

## 1. Go to module demo folder

```bash
cd cloud/w8/day-c/examples/module-demo
```

## 2. Initialize Terraform

```bash
terraform init
```

## 3. Format code

```bash
terraform fmt -recursive
```

## 4. Validate configuration

```bash
terraform validate
```

## 5. Preview changes

```bash
terraform plan
```

## 6. Apply changes

```bash
terraform apply
```

Type `yes` when Terraform asks for confirmation.

## 7. View output

```bash
terraform output
```

## 8. Check generated evidence file

Windows PowerShell:

```powershell
Get-Content generated/day-c-module-demo.txt
```

Git Bash / Linux / macOS:

```bash
cat generated/day-c-module-demo.txt
```

## 9. Destroy local resource

```bash
terraform destroy
```

## 10. Git commit

```bash
git add .
git commit -m "[W8-D3] terraform state modules and best practices"
git push origin main
```
