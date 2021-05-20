packer {
  required_plugins {
    windows-update = {
      version = "0.12.0"
      source = "github.com/rgl/windows-update"
    }
  }
}

# -------------------------------------------------------------------------- #
#                           Variable Definitions                             #
# -------------------------------------------------------------------------- #

# vCenter Credentials
variable "vcenter_username" {
    type        = string
    description = "The username Packer will use to login to vCenter"
    sensitive   = true
}
variable "vcenter_password" {
    type        = string
    description = "The password Packer will use to login to vCenter"
    sensitive   = true
}

# vCenter Configuration
variable "vcenter_server" {
    type        = string
    description = "The FQDN of vCenter"
}
variable "vcenter_datacenter" {
    type        = string
    description = "The name of the vSphere datacenter that Packer will use"
}
variable "vcenter_cluster" {
    type        = string
    description = "The name of the vSphere cluster that Packer will use"
}
variable "vcenter_datastore" {
    type        = string
    description = "The name of the datastore where Packer will create templates"
}
variable "vcenter_folder" {
    type        = string
    description = "The name of the folder where Packer will create templates"
}
variable "vcenter_network" {
    type        = string
    description = "The name of the network that Packer will attach templates to"
}

# vCenter and ISO Configuration
variable "vcenter_iso_datastore" {
    type        = string
    description = "The name of the datastore where Packer will attach ISO files from"
}
variable "os_iso_file" {
    type        = string
    description = "The name of the ISO file to be used for OS installation"
}
variable "os_iso_path" {
    type        = string
    description = "The path of the ISO file to be used for OS installation"
}
variable "tools_iso_file" {
    type        = string
    description = "The name of the ISO file to be used for Windows VMTools installation"
}
variable "tools_iso_path" {
    type        = string
    description = "The path of the ISO file to be used for Windows VMTools installation"
}

# OS Meta Data
variable "os_family" {
    type        = string
    description = "The family that guest OS belongs to (e.g. Windows, RedHat or CentOS etc)"
}
variable "os_version" {
    type        = string
    description = "The major version of guest OS that will be installed (e.g. 2019, 8, 4 etc)"
}

# Virtual Machine OS Settings
variable "vm_os_type" {
    type        = string
    description = "The vSphere guest OS identifier"
}
variable "vm_boot_cmd" {
    type        = list(string)
    description = "The sequence of command / keystrokes required to initiate guest OS boot / install"
}
variable "vm_shutdown_cmd" {
    type        = string
    description = "The command to be issued to shutdown the guest OS"
}


# Virtual Machine Hardware Settings
variable "vm_firmware" {
    type        = string
    description = "The type of firmware for the VM"
    default     = "bios"
}
variable "vm_cpu_sockets" {
    type        = number
    description = "The number of 'physical' CPUs to be configured on the VM"
}
variable "vm_cpu_cores" {
    type        = number
    description = "The number of cores to be configured per CPU on the VM"
}
variable "vm_mem_size" {
    type        = number
    description = "The size of the VM's virtual memory (in MB)"
}
variable "vm_nic_type" {
    type        = string
    description = "The type of network interface to configure on the VM"
}
variable "vm_disk_controller" {
    type        = list(string)
    description = "A list of the disk controller types to be configured (in order)"
}
variable "vm_disk_size" {
    type        = number
    description = "The size of the VM's system disk (in MB)"
}
variable "vm_disk_thin" {
    type        = bool
    description = "Indicates if the system disk should be thin provisioned"
}
variable "vm_cdrom_type" {
    type        = string
    description = "The type of CDROM device that should be configured on the VM"
}
variable "vm_video_memory" {
    type        = number
    description = "The size of the VM's video memory (in KB)"
}


# Provisioner Settings
variable "inline_cmds" {
    type        = list(string)
    description = "A list of commands that will be executed against the VM"
}

# Build Settings
variable "build_repo" {
    type        = string
    description = "The source control repository used to build the templates"
    default     = "https://github.com/jhoughes/packer"
}
variable "build_branch" {
    type        = string
    description = "The source control repository branch used to build the templates"
    default     = "none"
}
variable "build_username" {
    type        = string
    description = "The guest OS username used to login"
    default     = "Administrator"
    sensitive   = true
}
variable "build_password" {
    type        = string
    description = "The password for the guest OS username"
    sensitive   = true
}

# Local Variables
locals {
    build_version   = formatdate("MMDDYY", timestamp())
    build_date      = formatdate("MM-DD-YYYY hh:mm ZZZ", timestamp())
}


source "vsphere-iso" "win2019std" {
  # vCenter
  vcenter_server              = var.vcenter_server
  username                    = var.vcenter_username
  password                    = var.vcenter_password
  insecure_connection         = true
  datacenter                  = var.vcenter_datacenter
  cluster                     = var.vcenter_cluster
  folder                      = "${var.vcenter_folder}/${ var.os_family }/${ var.os_version }"
  datastore                   = var.vcenter_datastore
  remove_cdrom                = true
  convert_to_template         = true
  create_snapshot             = false

  # Virtual Machine
  guest_os_type               = var.vm_os_type
  vm_name                     = "win2019std-${ var.build_branch }-${ local.build_version }"
  notes                       = "VER: ${ local.build_version } (${ local.build_date })\nSRC: ${ var.build_repo } (${ var.build_branch })\nOS: Windows Server 2019 Standard\nISO: ${ var.os_iso_file }"

  #vm_version                  = var.vm_version
  firmware                    = var.vm_firmware
  CPUs                        = var.vm_cpu_sockets
  cpu_cores                   = var.vm_cpu_cores
  RAM                         = var.vm_mem_size
  boot_order                  = "cdrom,disk"
  cdrom_type                  = var.vm_cdrom_type
  disk_controller_type        = var.vm_disk_controller
  video_ram                   = var.vm_video_memory
  storage {
      disk_size               = var.vm_disk_size
      disk_controller_index   = 0
      disk_thin_provisioned   = var.vm_disk_thin
  }
  network_adapters {
      network                 = var.vcenter_network
      network_card            = var.vm_nic_type
  }

  floppy_files         = ["${path.root}/setup/"]

  iso_paths            = [  "[${var.vcenter_iso_datastore}] ISO/Windows/Server/en_windows_server_2019_updated_feb_2021_x64_dvd_277a6bfe.iso",
                            "[${var.vcenter_iso_datastore}] ISO/VMTools/VMware-tools-windows-11.2.5-17337674.iso"]

    # Boot and Provisioner
    boot_command                = var.vm_boot_cmd
    ip_wait_timeout             = "20m"
    communicator                = "winrm"
    winrm_timeout               = "2h"
    winrm_username              = var.build_username
    winrm_password              = var.build_password
    shutdown_command            = var.vm_shutdown_cmd
    shutdown_timeout            = "1h"


}

build {
    sources = [ "source.vsphere-iso.win2019std" ]

  provisioner "powershell" {
    inline = ["powercfg.exe /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"]
  }

  provisioner "windows-update" {
    filters         = ["exclude:$_.Title -like '*Preview*'", "include:$true"]
    search_criteria = "IsInstalled=0"
  }

}
