#!/bin/sh

MACHINENAME=${1:-HighOnLife} # Get machine name from arg or default

RAM=8096 # 8Gb memory
VRAM=256 # 256Mb video memory
DISK=80000 # 80Gb main disk
PORT=10001 # RDP Host port

#Prepare working dir
mkdir -p /root/vbox
cd /root/vbox

#Create VM
VBoxManage createvm --name $MACHINENAME --ostype "Ubuntu_64" --register --basefolder `pwd`

#Set memory and network
VBoxManage modifyvm $MACHINENAME --ioapic on
VBoxManage modifyvm $MACHINENAME --memory $RAM --vram $VRAM
VBoxManage modifyvm $MACHINENAME --nic1 nat

#Create Disk and connect Debian Iso
VBoxManage createhd --filename `pwd`/$MACHINENAME/$MACHINENAME_DISK_MAIN.vdi --size $DISK --format VDI
VBoxManage storagectl $MACHINENAME --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage storageattach $MACHINENAME --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium  `pwd`/$MACHINENAME/$MACHINENAME_DISK_MAIN.vdi
VBoxManage storagectl $MACHINENAME --name "IDE Controller" --add ide --controller PIIX4
VBoxManage storageattach $MACHINENAME --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium /root/ubuntu.iso
VBoxManage modifyvm $MACHINENAME --boot1 dvd --boot2 disk --boot3 none --boot4 none

#Enable RDP, multi-con, and set port.
VBoxManage modifyvm $MACHINENAME --vrde on
VBoxManage modifyVM $MACHINENAME --vrdemulticon on
VBoxManage modifyvm $MACHINENAME --vrdeport $PORT
