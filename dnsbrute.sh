#!/bin/bash
clear 
if [ $# -lt 1 ]; then
echo
echo "Mark's dns record brute forcer... suggest wordlist used is dnsnames.txt ;-)"
echo
echo "usage: dnsbrute.sh <domainroot> [Nameserver] [tcp] [wordlist]"
echo play with the grep params for clean results if you like.
echo
exit
fi

header="echo Marks dns record brute forcer...";

if [ $# -eq 1 ]; then
echo

$header 

echo the SOA for $1 is:
dig $1 SOA |grep -A100 'ANSWER SECTION' | grep SOA |grep -v \;
echo
echo
exit
fi

TCPOPT=""
if [ "$3" = "tcp" ];  
	then TCPOPT="+tcp"
fi

if test -e $4; then
list=$4
fi


function graball () {

digcmd="dig $TCPOPT @$2 $1"
$header
echo
echo "TCP options: "$TCPOPT
echo "wordlist used: "$list

echo 
echo the SOA is:
echo
$digcmd SOA |grep -A100 'ANSWER SECTION' | grep SOA |grep -v \;
echo

echo !!!!TRYING ZONE TRANSFER!!!
echo 
$digcmd AXFR |grep IN


echo
echo 'NS Records:'
echo
$digcmd NS | grep -A100 'ANSWER SECTION' |grep IN |grep NS | grep $1| sort |uniq | grep -v \;

echo
echo MX records:
$digcmd MX | grep -A100 'ANSWER SECTION' | grep IN | grep MX |grep $1| sort |uniq | grep -v \;

echo
echo simple A record check:
$digcmd @$2 $1  | grep -A100 'ANSWER SECTION' | grep IN | grep A |grep $1| sort |uniq | grep -v \;

echo
echo obtaining Active Directory service records:
array=(_ldap._tcp. _ldap._tcp.dc._msdcs. _ldap._tcp.pdc._msdcs. _ldap._tcp.gc.msdcs. _kpasswd._tcp. _kpasswd._udp. _msdcs. _gc._tcp. _kerberos._tcp. _kerberos._udp. _kerberos._tcp.dc._msdcs. _gc._msdcs.)
for i in "${array[@]}"; do
$digcmd @$2 $i$1 SRV | grep -A100 'ANSWER SECTION' | grep IN |grep SRV | sort | uniq |grep -v \;
done

echo
echo AUTHORITY: 
$digcmd @$2 $1 | grep -A100 'AUTHORITY' | grep IN |grep $1| sort |uniq | grep -v \;

echo
echo ADDITIONAL SECTION:
$digcmd @$2 $1 | grep -A100 'ADDITIONAL' | grep IN.*A | sort |uniq | grep -v \;

echo 
echo Hunt for the default _msdcs record
dig $TCPOPT @$2 _msdcs.$1 axfr |grep IN
echo
echo


echo
dnsnames=(mail www dc ftp dns ns3 exchange owa uat ntp time web webmail smtp pop pop3 nntp live secure test preprod prod production dev development rnd team barracuda imap intranet internet sharepoint isa iis star sun moon apple orange mailhub web citrix http smtp telnet data sql apache ext test default.first.site nis solaris linux ubuntu debian windows win2k win2k3 nt mysql postgres mssql data crest tiger) 
echo "Simple wordlist checks :"
appends=("" 01 02 03 04 05 1 2 3 4 5)
for i in "${dnsnames[@]}"; do
	for a in "${appends[@]}"; do
		#echo "trying: $i$a"
		digcmd="dig $TCPOPT @$2 $i$a.$1" 
		$digcmd A | grep -A100 'ANSWER SECTION' | grep IN | grep $1| sort |uniq | grep -v \; |more;
		done 
done

#cat /home/mark/vboxshare/wordlists/dnsnames.txt | xargs -i dig @$2 {}.$1 A | grep -A100 'ANSWER SECTION' | grep IN | grep $1| sort |uniq | grep -v \; |more
wait


echo "Guessing some records from wordlist : "$list
echo
cat $list | xargs -i dig $TCPOPT @$2 {}.$1 A | grep -A100 'ANSWER SECTION' | grep IN | grep $1| sort |uniq | grep -v \; |more
}

graball $1 $2 $3 $4 $TCPOPT $list


