# Maintaining that High On Life

# Snapshots

VM Snapshots allow you to save a specific state of your VM to a file and restore it later.

Snapshots are stored in the "Machine Folder". For a default HighOnLife setup this is `/root/vbox/HighOnLife/Snapshots`.

## Creating

Create a VBox snapshot using the following command:

`VBoxManage snapshot $MACHINENAME take $SNAPSHOTNAME [--description="Descriptive Text"`

If successful, the output will look something like this:

```
0%...10%...20%...30%...40%...50%...60%...70%...80%...90%...100%
Snapshot taken. UUID: 9486d408-bb05-4d17-9bac-8694466a4f8d
```

# Restoring

Restore using the following command

`VBoxManage snapshot $MACHINENAME restore $SNAPSHOTNAME`

## Listing

List available snapshots for your VM using:

`VBoxManage snapshot $MACHINENAME list [--detail]`

Example output:
```
Name: Baseline (UUID: 9486d408-bb05-4d17-9bac-8694466a4f8d) *
Description:
```

## More information

More information in [VirtualBox documentation](https://docs.oracle.com/en/virtualization/virtualbox/6.1/user/vboxmanage-snapshot.html)

