# encrypt.sh - script recursive encryption using GnuPG and and also calculates checksums sha512

**ATTENTION: this is an alpha version of the script, just after encryption, the ORIGINAL file is DELETED**
To change this, you need to comment out the line - 86 "/usr/bin/rm -f $1"

**Desctiption:
RUS:** Скрипт создает два временных скрипта, для вычисления контрольных сумм и шифрования. Так же создается два файла - первый со списком файлов необходимых для шифрования, второй список файлов, содержащий контрольные суммы файлов из списка один. Опцонально, но включенно по умолчанию - отправка на почту списка зашифрованных файлов. Для работы этого функционала, требуется установить дополнительный пакет mailx

**EN:** The script creates two temporary scripts, for calculating checksums and encryption. It also creates two files - the first with a list of files necessary for encryption, the second list of files containing checksums of files from the list one. Optionally, but it is enabled by default - send to the mail list of encrypted files. For this functionality to work, you need to install an additional package mailx


**_ENC_FOLER_** - variables, specifies the path to the target folder, the files in which you want to encrypt


