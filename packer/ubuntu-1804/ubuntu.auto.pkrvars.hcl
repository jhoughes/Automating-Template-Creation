# VM Hardware Settings
vm_cpu_sockets      = 1
vm_cpu_cores        = 1
vm_mem_size         = 2048
vm_nic_type         = "vmxnet3"
vm_disk_controller  = ["pvscsi"]
vm_disk_size        = 16384
vm_disk_thin        = true
vm_cdrom_type       = "sata"
vm_video_memory     = 16384

# VM OS Settings
vm_os_type          = "ubuntu64Guest"

# Provisioner Settings
http_directory      = "http"
preseed_path        = "preseed.cfg"