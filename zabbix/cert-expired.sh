# script check certificate expired day
# used for zabbix
#

#!/bin/bash
end_date=`echo | openssl s_client -connect $1:443 -servername $1 2>/dev/null | openssl x509 -noout -enddate`
end=$(cut -d= -f2- <<<"$end_date")
end_date=`date -d "$end" '+%s'`
curr_date=`date '+%s'`
diff=$(( $end_date - $curr_date ))
let "days = $diff / 86400"
echo $days
