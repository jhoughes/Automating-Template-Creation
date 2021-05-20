#Variables

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
    description = "The name of the network that Packer will attache templates to"
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
# See https://vdc-download.vmware.com/vmwb-repository/dcr-public/da47f910-60ac-438b-8b9b-6122f4d14524/16b7274a-bf8b-4b4c-a05e-746f2aa93c8c/doc/vim.vm.GuestOsDescriptor.GuestOsIdentifier.html
variable "vm_os_type" {
    type        = string
    description = "The vSphere guest OS identifier"
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
    description = "The size of the VM's virtual memory (in Mb)"
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
    description = "The size of the VM's video memory (in MB)"
}

# Provisioner Settings
variable "preseed_path" {
  type    = string
  default = "preseed.cfg"
}
variable "http_proxy" {
  type    = string
  default = "${env("http_proxy")}"
}
variable "https_proxy" {
  type    = string
  default = "${env("https_proxy")}"
}
variable "no_proxy" {
  type    = string
  default = "${env("no_proxy")}"
}
variable "http_directory" {
  type    = string
  default = "http"
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
    default     = "root"
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
    scripts_folder = "${path.root}/setup"
}

source "vsphere-iso" "ubuntu18" {

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
  guest_os_type     = var.vm_os_type
  vm_name           = "ubuntu-${ var.build_branch }-${ local.build_version }"
  notes             = "VER: ${ local.build_version } (${ local.build_date })\nSRC: ${ var.build_repo } (${ var.build_branch })\nOS: Ubuntu 18.04.5\nISO: ${ var.os_iso_file }"

  #vm_version                  = var.vm_version
  firmware                    = var.vm_firmware
  CPUs                        = var.vm_cpu_sockets
  cpu_cores                   = var.vm_cpu_cores
  CPU_hot_plug                = true
  RAM                         = var.vm_mem_size
  RAM_hot_plug                = true
  RAM_reserve_all             = false
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

  iso_paths            = [ "[${ var.vcenter_iso_datastore }] ${ var.os_iso_path }/${ var.os_iso_file }" ]

  boot_order                  = "cdrom,disk"
  boot_command        = [
                            "<esc><wait>",
                            "<esc><wait>",
                            "<enter><wait>",
                            "/install/vmlinuz<wait>",
                            " auto<wait>",
                            " console-setup/ask_detect=false<wait>",
                            " console-setup/layoutcode=us<wait>",
                            " console-setup/modelcode=pc105<wait>",
                            " debconf/frontend=noninteractive<wait>",
                            " debian-installer=en_US.UTF-8<wait>",
                            " fb=false<wait>",
                            " initrd=/install/initrd.gz<wait>",
                            " kbd-chooser/method=us<wait>",
                            " keyboard-configuration/layout=USA<wait>",
                            " keyboard-configuration/variant=USA<wait>",
                            " locale=en_US.UTF-8<wait>",
                            " netcfg/get_domain=vm<wait>",
                            " netcfg/get_hostname=ubuntu<wait>",
                            " grub-installer/bootdev=/dev/sda<wait>",
                            " noapic<wait>",
                            " file=/media/preseed.cfg<wait>",
                            " -- <wait>",
                            "<enter><wait>"
                        ]
  floppy_files         = ["${path.root}/setup/"]

  ssh_password        = var.build_password
  ssh_username        = var.build_username
  ssh_port            = 22
  ssh_timeout         = "10000s"
  shutdown_command    = "echo 'packer' | sudo -S shutdown -P now"

}

build {
  sources = ["source.vsphere-iso.ubuntu18"]

  provisioner "shell" {
    environment_vars  = ["HOME_DIR=/home/packer", "http_proxy=${var.http_proxy}", "https_proxy=${var.https_proxy}", "no_proxy=${var.no_proxy}"]
    execute_command   = "echo 'packer' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
    expect_disconnect = true
    scripts =   [
                    "${local.scripts_folder}/update.sh",
                    "${local.scripts_folder}/motd.sh",
                    "${local.scripts_folder}/sshd.sh",
                    "${local.scripts_folder}/networking.sh",
                    "${local.scripts_folder}/sudoers.sh",
                    "${local.scripts_folder}/vmware.sh",
                    "${local.scripts_folder}/cleanup.sh",
                    "${local.scripts_folder}/minimize.sh"
                ]


  }

}
