# Terraform bad examples for Terraform Quality Analyzer

These files are intentionally insecure/misconfigured and are meant only for testing your analyzer.

Expected rules to trigger, depending on your Checkov version and custom rule implementation:

- `public_storage`
- `CKV_AZURE_7` — public blob/container access type should be private
- `CKV_AZURE_35` — storage account default network access should be denied
- `CKV_AZURE_44` — storage account should use latest/minimum TLS version
- `CKV_AZURE_2` or similar public exposure check for VM/network/public IP
- `vm_backup_enabled_tag` — custom rule, if your backend receives its full config or it is saved in DB

Important:
- These files are valid HCL/Terraform syntax.
- They are intentionally unsafe and should not be deployed.
- If a specific CKV_AZURE_* rule does not trigger, check whether your selected Checkov ID matches the Azure resource/check in your installed Checkov version.
