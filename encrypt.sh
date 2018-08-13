#!/bin/bash

# Author  Denis Larkin
# version 0.1 alfa
# Recursive encryption and calculate hash sha512 files target folder

#set target folder for  encrypt
#TARGET_FOLDER=$1
TARGET_FOLDER=/example/path
# set temp  directory for file list path and temp script
TMP_DIR=/tmp

#set file name to save paths to encrypted files
FILE_NAME=$TMP_DIR/all-$(date +"%Y%m%d-%H%M%S")
#set file name to save sha512 path to encrypted files
FILES_SHA512=$TMP_DIR/sha512-$(date +"%Y%m%d-%H%M%S")

#gpg-enc script name
SHA512_SCRIPT=$TMP_DIR/sha512-calc-$(date +"%Y%m%d-%H%M%S").sh

#encrypt script name
GPG_ENC_SCRIP=$TMP_DIR/gpg-enc-$(date +"%Y%m%d-%H%M%S").sh


#create temp script for  calc sha512

cat > $SHA512_SCRIPT <<'EOT'
#!/bin/bash
# Author  Denis Larkin
# version 0.1 alfa

# calculate sha512 hash

#set full name include path
fullfile=$1
# only short name
fname=$(basename $fullfile)

if [ -d "$1" ]; then
     echo "is a direcotry  "$1""
   else
       	if [[ $1 == *.sha512 ]] || [[ $1 == *.gpg ]]
              then
                   echo "file "$1" already calculated hash sha512 or gpg"
                else
			echo "calculate hash "$1""
			#  set  default hash
			HASH_FILE="bad hash"
			# new calculate  hash
			HASH_FILE=$(/usr/bin/sha512sum $1 | cut -d ' ' -f 1)
			# create file sha512  insert hash and   only filename
			echo ""$HASH_FILE"  "$fname""> $1.sha512
              fi
        fi
EOT
####### end create script sha512

# set sha512 script executabe
/usr/bin/chmod +x  $SHA512_SCRIPT

### create temp encrypted script

cat > $GPG_ENC_SCRIP <<'EOT'

#!/bin/bash
# Author  Denis Larkin
# version 0.1 alfa

# encrypte file

#set recipient key
PUB_KEY=$2

#debug info
#echo  "pub key "$PUB_KEY""

if [ -d "$1" ]; then
     echo "is a direcotry  "$1""
   else
       	if [[ $1 == *.gpg ]]
              then
                   echo "file "$1" already encrypted gpg"
                else
			echo "encrypt "$1""
			/usr/bin/gpg --yes --batch --recipient $PUB_KEY --encrypt $1
			#delete encrypted file
			/usr/bin/rm -f $1
              fi
        fi
EOT
####### end create script gpg-ecn

# set encrypte script executabe
/usr/bin/chmod +x  $GPG_ENC_SCRIP


#### SMTP SECTION #########
# smtp server
SMTP_SERVER=mail.example.com
#mail for  report
MAIL_REPORT=user@example.com
#sender
FROM_SENDER='encrypted compleate <encrypt-server@example.com>'

#### end SMTP SECTION #####

#set GnuPG recipient key - SPECIFY YOUR PUBLIC KEY GnuPG
RECIPIENT_KEY=OUR-GPG-KEY

# create list files  for encrypt
/usr/bin/find $TARGET_FOLDER > $FILE_NAME

echo "create file  "$FILE_NAME" "
#set default variable
i=0
enc=none

#### section create sha512 and encrypt files to gpg
while read LINE
do
   i=$(($i + 1))

# calc hash
    /usr/bin/sh $SHA512_SCRIPT  "${LINE}"
# encrypt
   /usr/bin/sh $GPG_ENC_SCRIP "${LINE}" "$RECIPIENT_KEY"
done < $FILE_NAME

###### end encrypt files

#create list files name *.sha512 and encrypted their
# sha512 files
/usr/bin/find $TARGET_FOLDER -type f -name '*.sha512'> $FILES_SHA512
echo "file sha512 "$FILES_SHA512""

while read LINE
do
# encrypt  sha512 files
#   ./gpg-enc.sh "${LINE}" "$RECIPIENT_KEY"
   /usr/bin/sh $GPG_ENC_SCRIP "${LINE}" "$RECIPIENT_KEY"

done < $FILES_SHA512

### enc encrypted files *.sha512

# debug section
echo "list file include "$i" string"
# end section

########  OPTIONAL: send list encrypted files
# send mail use  mailx
# install mailx for centos 7.5
# yum -y install mailx
echo "attach list encrypted files " | /usr/bin/mailx -a $FILE_NAME -s "encrypt compleate" -S smtp=smtp://$SMTP_SERVER -S from="$FROM_SENDER" $MAIL_REPORT

# remove temp file
echo "remove temp file "$FILE_NAME""
/usr/bin/rm -f $FILE_NAME
echo "remove temp file "$FILES_SHA512""
/usr/bin/rm -f $FILES_SHA512

echo "remove temp file "$SHA512_SCRIPT""
/usr/bin/rm -f $SHA512_SCRIPT

echo "remove temp file "$GPG_ENC_SCRIP""
/usr/bin/rm -f $GPG_ENC_SCRIP


echo "send  list encrypted file compleate"


####### END
