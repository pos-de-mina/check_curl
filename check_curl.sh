#!/bin/bash
#
# R E F
#     - https://curl.haxx.se/docs/manpage.html
#
# (c) 2019-06-22 Antonio Pos-de-Mina

curl_url=$1
curl_proxy=$2
curl_metrics='curl_http_code=%{http_code}\ncurl_time_total=%{time_total}\ncurl_size_download=%{size_download}\n'

# clean last call
rm -f ~/tmp/curl_log_*

curl $curl_url --proxy $curl_proxy -w $curl_metrics --output ~/tmp/curl_log_stdout_$$ --stderr ~/tmp/curl_log_stderr_$$ --trace ~/tmp/curl_log_trace-$$ > ~/tmp/curl_log_metrics-$$
curl_rc=$?

if [ "$curl_rc" -eq "0" ]
then
        source ~/tmp/curl_log_metrics-$$
        echo -e "HTTP $curl_http_code; Response Time $curl_time_total; Response Size $curl_size_download\n$(cat ~/tmp/curl_log_stdout_$$)|Response_Time=$curl_time_total Response_Size=$curl_size_download HTTP_Return_Code=$curl_http_code"
        if [ "$curl_http_code" -ge "500" ]
        then
                exit 2
        elif [ "$curl_http_code" -ge "400" ]
        then
                exit 1
        elif [ "$curl_http_code" -ge "300" ]
        then
                exit 1
        else
                exit 0
        fi
else
        # error code
        curl_error=$(awk -v line=$curl_rc 'NR == line{print $0}' /omd/scripts/curl_error_map.txt)
        echo "$curl_error|Response_Time=$curl_time_total Response_Size=$curl_size_download HTTP_Return_Code=$curl_http_code"
        exit 2
fi
