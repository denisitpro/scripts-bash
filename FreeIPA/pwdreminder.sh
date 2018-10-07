#!/bin/bash

# Хост через который шлем почтовые сообщения
MX_HOST="smtp.example.com"

# Наводим красоту
RU_MONTH[1]="Января"
RU_MONTH[2]="Февраля"
RU_MONTH[3]="Марта"
RU_MONTH[4]="Апреля"
RU_MONTH[5]="Мая"
RU_MONTH[6]="Июня"
RU_MONTH[7]="Июля"
RU_MONTH[8]="Августа"
RU_MONTH[9]="Сентября"
RU_MONTH[10]="Октября"
RU_MONTH[11]="Ноября"
RU_MONTH[12]="Декабря"

# Используем токены через gssproxy
export GSS_USE_PROXY="yes"

# Функция вычисления дней
function calculate_days() {
	days=$((($(date -d "${year}${month}${cday}" +%s) - $(date +%s))/86400))
}

# Функция конвертации дат
function convert_date() {
	year=$(date -d "${expdate:0:8} ${expdate:8:2}:${expdate:10:2}:${expdate:12:2}" +%Y)
	month=$(date -d "${expdate:0:8} ${expdate:8:2}:${expdate:10:2}:${expdate:12:2}" +%m)
	cday=$(date -d "${expdate:0:8} ${expdate:8:2}:${expdate:10:2}:${expdate:12:2}" +%d)
	day=$(date -d "${expdate:0:8} ${expdate:8:2}:${expdate:10:2}:${expdate:12:2}" +%e)
}

# Посылаем уведомления
function send_user_notify()	{
	convert_date
	calculate_days
	(( "$days" < "0" )) && return 0
	cat << EOF | mailx -S smtp=${MX_HOST} -r "noreply@example.com" -s "Your Network password in domain.example.com will expire in ${days} day(s), please change your password" ${mail}
Добрый день!
${day} ${RU_MONTH[$month]} ${year} истекает пароль к вашей учетной записи ${uid} находящейся в тестовом домене domain.example.com.
Просьба произвести плановое изменение пароля, в противном случае Вы потеряете доступ к ИТ сервисам компании.
Вы можете поменять пароль, перейдя по ссылке https://ipa.example.com.
Пароль к обычной учетной записи должен состоять из прописных, строчных букв и цифр и быть длинной не менее 15 символов.
Пароль к а-записи - не менее 21 символа.

EOF
}

function send_admin_notify() {
	LANG=
	export LANG
	(
		echo "Accounts with expiring passwords for $(date) are:"
		for line in "${ANOTIFYEXPIRES[@]}"; do 
			echo $line
		done

		echo ""
		echo "Accounts with expired passwords are:"
		for line in "${ANOTIFYEXPIRED[@]}"; do 
			echo $line
		done
	) | mailx -S smtp=${MX_HOST} -r "noreply@example.com" -s "IPA REPORT: Password change for domain.example.com for $(date)" sysadmins@example.com
}

function add_admin_notify() {
	if (( "$days" < 0 )); then
		ANOTIFYEXPIRED[${#ANOTIFYEXPIRED[@]}]=" - ${uid} (${mail}) Pass has expired ${expdate:0:4}-${expdate:4:2}-${expdate:6:2} ${expdate:8:2}:${expdate:10:2}:${expdate:12:2}"
	else
		ANOTIFYEXPIRES[${#ANOTIFYEXPIRES[@]}]=" - ${uid} (${mail}) Pass expires ${expdate:0:4}-${expdate:4:2}-${expdate:6:2} ${expdate:8:2}:${expdate:10:2}:${expdate:12:2}"
	fi
}

while read line; do
	#echo $line
	if [[ $line =~ ^$ ]]; then
		if [[ -n "$dn" ]]; then
			send_user_notify
			add_admin_notify
		fi
		dn=""
		continue
	fi
	if [[ "$line" =~ ^dn: ]]; then
		dn="${line:4}"
		continue
	fi
	if [[ -n "$dn" && $line =~ ^uid: ]]; then
		uid=${line:5}
		continue
	fi
	if [[ -n "$dn" && $line =~ ^mail: ]]; then
		mail=${line:6}
		continue
	fi
	if [[ -n "$dn" && $line =~ ^krbPasswordExpiration: ]]; then
		expdate=${line:23}
		continue
	fi
done < <(ldapsearch -Y GSSAPI "(&(!(nsAccountLock=TRUE))(krbLastPwdChange<=$(date +%Y%m%d --date='-1 week')000000Z)(krbPasswordExpiration<=$(date +%Y%m%d --date='+1 week')000000Z))" uid mail krbPasswordExpiration)

if [[ -n "$dn" ]]; then
	send_user_notify
	add_admin_notify
fi

send_admin_notify
