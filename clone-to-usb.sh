#!/bin/bash

# Initiates an rsync session to backup volume1 to volumeUSB1
# You can pass any valid rsync options or a custom option below

help="
Initiates an rsync session to backup volume1 to volumeUSB1
Use any valid rsync options or the optins defined below:
--dry-run       Do not copy files, just output what whoud have beed done
--log-diff      Write all rsync changes to file (uses default file name or provide custom)
                * this is the default behavior
--log-all       Write all output to file (uses default file or provide custom)
--target        Modify the target path
--source        Modify the source path
--silent        Only write to files, do not output to tty
--verbose       Write all rsync output to tty, not just diff
--two-way       Sync both directions, adds target -> source in addition to source -> target
"

# CONFIG
diff_file="./rsync_diff.txt"
target_dir="/volumeUSB1/usbshare/SynoClone/"
source_dir="/volume1/"
silent=""
dry_run=""
log_file=""
options=""
output_diff="/dev/tty"
output_all="/dev/null"
two_way=""

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
     --two-way) two_way=true;;
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
                    target_dir="$2"
                    shift
                else
                    echo "target requires an argument"
                    exit
                fi
                ;;
      --source) if [ "$2" ] && [[ ! $2 =~ ^- ]]; then
                    source_dir="$2"
                    shift
                else
                    echo "source requires an argument"
                    exit
                fi
                ;;
             *) add_option "$1"
                ;;
    esac
    shift
done

if [ "$dry_run" ]; then
  echo "RUNNING RSYNC TO USB (** DRY RUN **)"
else
  echo "RUNNING RSYNC TO USB"
fi

# Modify screen output
if [ "$verbose" ]; then
  output_all="/dev/tty"
  output_diff="/dev/null"
fi

if [ "$silent" ]; then
  echo " silent mode : see diff file for changes"
  output_all="/dev/null"
  output_diff="/dev/null"
fi

# Add files to output
if [ "$log_file" ]; then
  output_all="$output_all $log_file"
fi

# Ouptut config to screen
echo " source    : $source_dir"
echo " target    : $target_dir"
if [ "$output_all" ]; then
  echo " log all   : $output_all"
fi
if [ "$output_diff" ]; then
  echo " log diff  : $output_diff $diff_file"
fi
echo " options   : $options"

# RUN RSYNC COMMAND (syno to usb)
rsync --archive --progress --verbose --inplace --itemize-changes --delete \
--exclude '@*' --exclude 'aquota*' --exclude 'synoquota*' --exclude '*.vsmeta' --exclude '.DS_Store' --exclude '#recycle/*' \
$options "$source_dir" "$target_dir" | tee $output_all | grep --line-buffered '^>\|^<\|^*deleting' | tee $diff_file > $output_diff

echo "Finished $source_dir -> $target_dir"

[ ! "$two_way"] && exit

# RUN RSYNC COMMAND (usb to syno)
rsync --archive --progress --verbose --inplace --itemize-changes --delete \
--exclude '@*' --exclude 'aquota*' --exclude 'synoquota*' --exclude '*.vsmeta' --exclude '.DS_Store' --exclude '#recycle/*' \
$options "$target_dir" "$source_dir" | tee $output_all | grep --line-buffered '^>\|^<\|^*deleting' | tee $diff_file > $output_diff

echo "Finished $target_dir -> $source_dir"
