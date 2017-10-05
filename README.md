# synology-clone-to-usb

A simple script to clone your synology volume to a usb conected drive  via rsync.

Use can pass any valid rsync options or the optins defined below:

Options in bold are used by default, only required to modify the default value.

--**log-diff** : Write only changed files to the specified log file (uses `./rsync_diff.txt` or provide custom file) 

--log-all  : Write all output to file (uses `./rsync_log.txt` or provide custom file)

--target-root :  Modify the target root (default `/volumeUSB1/usbshare/`)

--target-dir  :  Modify the target directory (default `SynoClone`)

--target : Modify the full target path (default `/volumeUSB1/usbshare/SynoClone`)

--dry-run : Do not copy files, just output what whoud have beed done

--silent : Only write to files, do not output modified files to tty

--verbose : Write all rsync output to tty, not just the modified files


