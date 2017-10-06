# synology-clone-to-usb

A simple script to clone your synology volume to a usb connected drive via rsync.  A log file containing all modified files is automatically generated in the directory the command was executed.  You can pass any valid rsync options or the options defined below.  

## Run manually

Copy the `cone-to-usb.sh` script to a location on your volume.

Use ssh to access your synology device `ssh admin_user@synology_ip_address`

Run the script as desired (see usage examples)

## Setup synology task

Copy the `cone-to-usb.sh` script to a location on your volume.

On your synology device log in to DSM and navigate to control panel > task scheduler.

Choose `create` and configure as desired.  Under task settings > User-defined script enter the full path to the script plus any options you want to use (see usage examples).

## Options

Options in bold set by default, only required to modify the default value.

--**log-diff** : Write only changed files to the specified log file (uses `./rsync_diff.txt` or provide custom file)

--log-all  : Write all output to file (uses `./rsync_log.txt` or provide custom file)

--target : Modify the full target path (default `/volumeUSB1/usbshare/SynoClone`)

--source : Modify the full target path (default `/volumeUSB1/usbshare/SynoClone`)

--dry-run : Do not copy files, just output what would have beed done

--silent : Only log output to file, do not output modified files to tty (use this option if running as a scheduled task)

--verbose : Write all rsync output to tty, not just the modified files

--two-way : Sync target -> source in addition to source -> target

## Usage examples

Log only modified files to tty and write to ./rsync_diff.txt

    ./clone_to_usb.sh

Log only modified files to file with no output to tty (this is good for synology task runner)

    ./clone_to_usb.sh --silent

Log only modified files to tty and write all rsync output to ./rsync_log.txt

    ./clone_to_usb.sh --log-all

Log all rsync output to tty and write to /temp/rsync_all.txt

    ./clone_to_usb.sh --verbose --log-all /temp/rsync_all.txt
