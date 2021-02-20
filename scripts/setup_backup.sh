#!/usr/bin/env bash

source ${BASH_SOURCE%/*}/variables.sh

echo -e "\n\n### Setting up Backups ###\n\n"

# Test to make sure we're mounted or exit
if $(mountpoint -q "${RCLONE_BACKUP_DIR}"); then
    echo "${RCLONE_BACKUP_DIR} is mounted. Let's do this!"
else
    echo "${RCLONE_BACKUP_DIR}is not mounted. Exiting"
    exit 1
fi

# Loop over services defined
for SERVICE in "${!SERVICES[@]}"; do

  BACKUPDIR=${RCLONE_BACKUP_DIR}/${SERVICE}
  if [ ! -d "${BACKUPDIR}" ]; then
    # Create backup directory
    echo "Directory ${BACKUPDIR} not found. Creating."
    mkdir -p ${BACKUPDIR}
  fi

  # Change directory permissions
  echo "Changing ${BACKUPDIR} permissions to: ${PLEX_USER}.${PLEX_GROUP}"
  chown -R ${PLEX_USER}.${PLEX_GROUP} ${BACKUPDIR}

done

# Get current directory of the repo scripts directory
REPO_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )

# Setup cronjob
echo "Copying backup configuration to /etc/cron.d"
cp ${BASH_SOURCE%/*}/../cron/plex-backups ${CRON_DIR}
sed -i "s~%%SCRIPT_REPO%%~${REPO_DIR}~" ${CRON_DIR}/plex-backups
systemctl restart crond

echo "Done setting up backups"
