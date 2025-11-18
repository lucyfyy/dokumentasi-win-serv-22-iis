# Path backup firewall
$BackupPath = "C:\Firewall-Backup.wfw"

# Export semua konfigurasi firewall
netsh advfirewall export $BackupPath
Write-Output "Backup disimpan di $BackupPath"

# Hapus semua inbound rules (opsional, bisa dihapus jika tidak mau)
Get-NetFirewallRule -Direction Inbound | Remove-NetFirewallRule -Confirm:$false

# Set default inbound = Block
Set-NetFirewallProfile -Profile Domain,Private,Public -DefaultInboundAction Block