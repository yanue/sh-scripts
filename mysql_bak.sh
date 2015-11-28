#!/bin/bash
#Author absolutely.xu@gmail.com
MAXIMUM_BACKUP_FILES=10              #
BACKUP_PATH="/opt/data_bak"  #
BACKUP_FOLDER_PREFIX="db"  #
DB_HOSTNAME="127.0.0.1"              #mysql
DB_USERNAME="root"                   #mysql
DB_PASSWORD=""                 #mysql
DATABASES=(
        "saleasy"
)
#=========
echo "Bash Database Backup Tool"
cd $BACKUP_PATH
echo "cd into backup folder path"
#CURRENT_DATE=$(date +%F)
CURRENT_DATE=$(date +%F)              #
BACKUP_FOLDER="${BACKUP_FOLDER_PREFIX}_${CURRENT_DATE}" #
mkdir $BACKUP_FOLDER #
#
count=0
while [ "x${DATABASES[count]}" != "x" ];do
    count=$(( count + 1 ))
done
echo "[+] ${count} databases will be backuped..."
#
for DATABASE in ${DATABASES[@]};do
    echo "[+] Mysql-Dumping: ${DATABASE}"
    echo -n "   Began:  ";echo $(date)
    if $(mysqldump -h ${DB_HOSTNAME} -u${DB_USERNAME} -p${DB_PASSWORD} ${DATABASE} > "${BACKUP_FOLDER}/${DATABASE}.sql");then
        echo "  Dumped successfully!"
    else
        echo "  Failed dumping this database!"
    fi
        echo -n "   Finished: ";echo $(date)
done
echo
echo "[+] Packaging and compressing the backup folder..."
tar -cv ${BACKUP_FOLDER} | bzip2 > ${BACKUP_FOLDER}.tar.bz2 && rm -rf $BACKUP_FOLDER
BACKUP_FILES_MADE=$(ls -l ${BACKUP_FOLDER_PREFIX}*.tar.bz2 | wc -l)
BACKUP_FILES_MADE=$(( $BACKUP_FILES_MADE - 0 ))
#

echo
echo "[+] There are ${BACKUP_FILES_MADE} backup files actually."
#,
if [ $BACKUP_FILES_MADE -gt $MAXIMUM_BACKUP_FILES ];then
    REMOVE_FILES=$(( $BACKUP_FILES_MADE - $MAXIMUM_BACKUP_FILES ))
echo "[+] Remove ${REMOVE_FILES} old backup files."
#
    ALL_BACKUP_FILES=($(ls -t ${BACKUP_FOLDER_PREFIX}*.tar.bz2))
    SAFE_BACKUP_FILES=("${ALL_BACKUP_FILES[@]:0:${MAXIMUM_BACKUP_FILES}}")
echo "[+] Safeting the newest backup files and removing old files..."
    FOLDER_SAFETY="_safety"
if [ ! -d $FOLDER_SAFETY ]
then mkdir $FOLDER_SAFETY

fi
for FILE in ${SAFE_BACKUP_FILES[@]};do

    mv -i  ${FILE}  ${FOLDER_SAFETY}
done
    rm -rf ${BACKUP_FOLDER_PREFIX}*.tar.bz2
    mv  -i ${FOLDER_SAFETY}/* ./
    rm -rf ${FOLDER_SAFETY}
fi

#crontab
# crontab -e
# 0 05 * * * /opt/data_bak/mysql_bak.sh
