# Installing HighOnLife VBox RDP

Instructions to set up VirtualBox RDP with Ubuntu 64 Guest OS. Ubuntu ships with VirtualBox 5.2. 
See chapter "VirtualBox 6" on how to use a more up to date VirtualBox.

## Prerequisites for a dream

We'll be using Ubuntu as guest os. Get the download link from https://ubuntu.com/download/desktop

We'll also need VirtualBox Extension Pack. Get the download link here: https://www.virtualbox.org/wiki/Download_Old_Builds_5_2 (Note that this download link is for 5.2 only. Download recent ext-pack if you're using VirtualBox 6)

Download both files onto your host OS using `wget`.

# Installation

## Install VirtualBox

Simply run `apt install virtualbox`
This installs the version currently shipped with your distribution. For an up-to-date installation, see chapter "VirtualBox 6"

Rename your fresh Ubuntu image download to `/root/ubuntu.iso`.

As user root, perform the following steps, or run `setup_vbox.sh`. The steps below use the same values for RAM/VRAM/DISK size as setup_vbox.sh.
You can modify these to fit your needs.

```
#Prepare working dir
mkdir -p /root/vbox
cd /root/vbox

#Create VM
VBoxManage createvm --name $MACHINENAME --ostype "Ubuntu_64" --register --basefolder `pwd`
#Set memory and network
VBoxManage modifyvm $MACHINENAME --ioapic on
VBoxManage modifyvm $MACHINENAME --memory 8096 --vram 256
VBoxManage modifyvm $MACHINENAME --nic1 nat
#Create Disk and connect Debian Iso
VBoxManage createhd --filename `pwd`/$MACHINENAME/$MACHINENAME_DISK.vdi --size 80000 --format VDI
VBoxManage storagectl $MACHINENAME --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage storageattach $MACHINENAME --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium  `pwd`/$MACHINENAME/$MACHINENAME_DISK.vdi
VBoxManage storagectl $MACHINENAME --name "IDE Controller" --add ide --controller PIIX4
VBoxManage storageattach $MACHINENAME --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium /root/debian.iso
VBoxManage modifyvm $MACHINENAME --boot1 dvd --boot2 disk --boot3 none --boot4 none

#Enable RDP, multi-con, and set port.
VBoxManage modifyvm $MACHINENAME --vrde on
VBoxManage modifyVM $MACHINENAME --vrdemulticon on
VBoxManage modifyvm $MACHINENAME --vrdeport 10001
```
## VirtualBox Extension Pack

While already installed, there is a change that you need to update/reinstall VirtualBox extensionpack. 
Download it using the link from the prerequisites and run the following commands:

```
VBoxManage extpack uninstall VNC
VBoxManage extpack install --replace Oracle_VM_VirtualBox_Extension_Pack-5.2.44.vbox-extpack
```

# Security

Before we can expose our previous VirtualBox RDP to the internet we must set up some security for our server.

As user root, perform the following steps. There is no script, as most commands are interactive (just smash enter).

```
# Allow clients to negotiate RDP security
vboxmanage modifyvm $MACHINENAME --vrdeproperty "Security/Method=negotiate"

# Prepare ssl config dir
mkdir -p /root/vbox/etc/ssl
cd /root/vbox/etc/ssl

# Create SSL cert
openssl req -new -x509 -days 365 -extensions v3_ca -keyout ca_key_private.pem -out ca_cert.pem -nodes
openssl genrsa -out server_key_private.pem
openssl req -new -key server_key_private.pem -out server_req.pem
openssl x509 -req -days 365 -in server_req.pem -CA ca_cert.pem -CAkey ca_key_private.pem -set_serial 01 -out server_cert.pem

# Configure server to use SSL certs
vboxmanage modifyvm $MACHINENAME --vrdeproperty "Security/CACertificate=/root/vbox/etc/ssl/ca_cert.pem"
vboxmanage modifyvm $MACHINENAME --vrdeproperty "Security/ServerCertificate=/root/vbox/etc/ssl/server_cert.pem"
vboxmanage modifyvm $MACHINENAME --vrdeproperty "Security/ServerPrivateKey=/root/vbox/etc/ssl/server_key_private.pem"

# Enable RDP Authentication for host and VM
VBoxManage setproperty vrdeauthlibrary "VBoxAuthSimple"
VBoxManage modifyvm $MACHINENAME --vrdeauthtype external

# Generate a password hash
VBoxManage internalcommands passwordhash "okelidokeli"

# Use the generated hash to create user/password. Default HighOnLife user is "ned". Feel free to pick something funnier.
VBoxManage setextradata "My VM" "VBoxAuthSimple/users/ned" 2bb80d537b1da3e38bd30361aa855686bde0eacd7162fef6a25fe97bf527a25b
```

# Fire it up

You can now start your headless VirtualBox:

```
VBoxHeadless --startvm $MACHINENAME
```

You should be greeted by something like:
```
Oracle VM VirtualBox Headless Interface 5.1.38
  (C) 2008-2018 Oracle Corporation
  All rights reserved.
  VRDE server is listening on port 10001.
```

# Clients

For Windows 10 and Mac OSX download "Microsoft Remote Desktop" from the Windows/Apple Store. Do not attempt to use the default Remote Desktop Connection app on windows 10. 

When connecting you will be warned about the self signed certificate you created. You can safely accept the certificate and enter your credentials. 

You should be greated by an Ubuntu installation screen and you can continue with a normal Ubuntu installation in your new Vbox. Cheers.

# VirtualBox 6

Want to use an up-to-date VirtualBox version. Easy! Add the following to your apt sources by creating a new file `/etc/apt/sources.list.d/virtualbox.list` with the following content:

`deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian <mydist> contrib`

Replace `<mydist>` with your current ubuntu/debian flavor (e.g. bionic)

Update and install: `apt update && apt install virtualbox`. Now do the rest of the installation.
