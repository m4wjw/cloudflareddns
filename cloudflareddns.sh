#!/bin/bash

#read -p "Please enter the global api key of the your account : " -t 30 globalid
#read -p "Please enter your email which you use to login the cloudflare : " -t 30 email
#read -p "Please enter the zoneid of your the domain which your want to modify : " zoneid
#read -p "Please enter the zone(hostname) : " -t 30 zone

#echo $globalid,$email,$zoneid,$zone

ip=$(curl -s https://ipv4.icanhazip.com)
#echo $ip

zoneid=$3
globalid=$1
email=$2
zone=$4

result=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zoneid/dns_records?type=A&name=$zone" \
     -H "X-Auth-Email: $email" \
     -H "X-Auth-Key: $globalid" \
     -H "Content-Type: application/json")
#echo $result | jq -r '.result[0].id'
dnsid=$(echo $result | jq -r '.result[0].id')

result2=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zoneid/dns_records/$dnsid" \
     -H "X-Auth-Email: $email" \
     -H "X-Auth-Key: $globalid" \
     -H "Content-Type: application/json" \
     --data '{"type":"A","name":"'$zone'","content":"'$ip'","ttl":120,"proxied":false}')

answer=$(echo $result2 | jq -r '.success')
#echo $answer

if [ $answer = true ]
then
	echo "Update successfully!"
else 
	echo "Update failure! Check the error log in /var/log/cloudflareddns_error.log"
	echo "[ $(date +"%F %T") ]" $result2 >> /var/log/cloudflareddns_error.log
fi
