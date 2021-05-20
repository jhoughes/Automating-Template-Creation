# VM Hardware Settings
vm_cpu_sockets      = 2
vm_cpu_cores        = 1
vm_mem_size         = 2048
vm_nic_type         = "vmxnet3"
vm_disk_controller  = ["pvscsi"]
vm_disk_size        = 51200
vm_disk_thin        = true
vm_cdrom_type       = "sata"
vm_video_memory     = 16384
vm_firmware         = "bios"

# VM OS Settings
vm_os_type          = "windows2019srv_64Guest"
vm_boot_cmd         = ["<spacebar>"]
vm_shutdown_cmd     = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Complete\""

# Provisioner Settings

inline_cmds         = [ "Get-EventLog -LogName * | ForEach { Clear-EventLog -LogName $_.Log }" ]