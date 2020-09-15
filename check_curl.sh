#!/bin/bash
# /omd/_custom/plugins/check_curl.sh
# R E F
#   - https://curl.haxx.se/docs/manpage.html
#
# (c) 2019-06-22 Antonio Pos-de-Mina

curl_url=$1
curl_proxy=$2
curl_metrics='curl_http_code=%{http_code}\ncurl_time_total=%{time_total}\ncurl_size_download=%{size_download}\n'

export status=0

curl $curl_url --proxy $curl_proxy -w $curl_metrics --output ~/tmp/curl_log_$$.stdout --stderr ~/tmp/curl_log_$$.stderr --trace ~/tmp/curl_log_$$.trace > ~/tmp/curl_log_$$.metrics
curl_rc=$?

if (( $curl_rc = 0 ))
then
  source ~/tmp/curl_log_$$.metrics
  echo -e "HTTP $curl_http_code; Response Time $curl_time_total; Response Size $curl_size_download\n$(cat ~/tmp/curl_log_stdout_$$)|Response_Time=$curl_time_total Response_Size=$curl_size_download HTTP_Return_Code=$curl_http_code"
  if [ "$curl_http_code" -ge "500" ]
  then
    export status=2
  elif [ "$curl_http_code" -ge "400" ]
  then
    export status=1
  elif [ "$curl_http_code" -ge "300" ]
  then
    export status=1
  fi
else
  # error code
  curl_error=$(awk -v line=$curl_rc 'NR == line{print $0}' /omd/_custom/plugins/curl_error_map.txt)
  echo "$curl_error|Response_Time=$curl_time_total Response_Size=$curl_size_download HTTP_Return_Code=$curl_http_code"
  export status=2
fi

# clean last call
rm -f ~/tmp/curl_log_$$*

exit $status
