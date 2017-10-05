#!/bin/sh

# Initiates an rsync session to backup volume1 to volumeUSB1
# You can pass any valid rsync options or a custom option below

help="
Initiates an rsync session to backup volume1 to volumeUSB1
Use any valid rsync options or the optins defined below:
--dry-run       Do not copy files, just output what whoud have beed done
--log-diff      Write all rsync changes to file (uses default file name or provide custom)
                * this is the default behavior
--log-all       Write all output to file (uses default file or provide custom)
--target-root   Modify the target root
--target-dir    Modify the target directory
--target        Modify the full target path
--silent        Only write to files, do not output to tty
--verbose       Write all rsync output to tty, not just diff
"

# CONFIG
diff_file="./rsync_diff.txt"
target_root="/volumeUSB1/usbshare"
target_dir="SynoClone"
target=""
silent=""
dry_run=""
log_file=""
options=""

# OPTIONS

add_option () {
  if [ "$options"]; then
    options="$options $@"
  else
    options="$@"
  fi
}

while [ $# -gt 0 ];do
    case "$1" in
        --help) echo "$help" && exit;;
      --silent) silent=true;;
     --verbose) verbose=true;;
     --dry-run) dry_run=true
                add_option "$1"
                ;;
     --log-all) if [ "$2" ] && [[ ! $2 =~ ^- ]]; then
                    log_file="$2"
                    shift
                else
                    log_file="./rsync_log.txt"
                fi
                ;;
    --log-diff) if [ "$2" ] && [[ ! $2 =~ ^- ]]; then
                    diff_file="$2"
                    shift
                fi
                ;;
      --target) if [ "$2" ] && [[ ! $2 =~ ^- ]]; then
                    target="$2"
                    shift
                else
                    echo "target requires a deriectory"
                    exit
                fi
                ;;
 --target-root) if [ "$2" ] && [[ ! $2 =~ ^- ]]; then
                    target_root="$2"
                    shift
                else
                    echo "target_root requires a deriectory"
                    exit
                fi
                ;;
  --target-dir) if [ "$2" ] && [[ ! $2 =~ ^- ]]; then
                    target_dir="$2"
                    shift
                else
                    echo "target_dir requires a deriectory"
                    exit
                fi
                ;;
             *) add_option "$1"
                ;;
    esac
    shift
done

target="${target_root}/${target_dir}/"

if [ "$dry_run" ]; then
  echo "RUNNING RSYNC TO USB (** DRY RUN **)"
else
  echo "RUNNING RSYNC TO USB"
fi

# Modify screen output
if [ "$verbose" ]; then
  output="/dev/tty"
  output_diff="/dev/null"
fi

if [ "$silent" ]; then
  echo " silent mode : see diff file for changes"
  output="/dev/null"
  output_diff="/dev/null"
fi

# Add files to output
output="$log_file $output"
output_diff="$diff_file $output_diff"


echo " target    : $target"
echo " log all   : $output"
echo " log diff  : $output_diff"
echo " options   : $options"

# RUN RSYNC COMMAND
sudo rsync --archive --progress --verbose --inplace --itemize-changes \
--exclude '@*' --exclude 'aquota*' --exclude 'synoquota*' --exclude '*.vsmeta' --exclude '.DS_Store' \
"$options" /volume1/ "$target" | tee $output | grep --line-buffered '^>\|^<' | tee $output_diff
