wget --no-check-certificate http://sbc.io/hosts/alternates/fakenews-gambling-porn/hosts -O - |sed 's/^0.0.0.0 /127.0.0.1 /g' |grep 127.0.0.1 >/tmp/hosts

cat /tmp/hosts |sed 's/\r//g' | sed 's/127.0.0.1 /DOMAIN-SUFFIX,/g' |sed 's/$/,Reject/g'  > /tmp/union.conf2 
cat /tmp/union.conf2 | sed 's/\r//g' |grep -v "#"  |sort -du  > /tmp/union.conf3

echo '
[General]
bypass-system = true
skip-proxy = 192.168.0.0/16, 10.0.0.0/8, 172.16.0.0/12, localhost, *.local, e.crashlytics.com, captive.apple.com
bypass-tun = 10.0.0.0/8,100.64.0.0/10,127.0.0.0/8,169.254.0.0/16,172.16.0.0/12,192.0.0.0/24,192.0.2.0/24,192.88.99.0/24,192.168.0.0/16,198.18.0.0/15,198.51.100.0/24,203.0.113.0/24,224.0.0.0/4,255.255.255.255/32
dns-server = system, 223.5.5.5, 112.124.47.27, 8.8.8.8, 8.8.4.4
[Rule]

DOMAIN-SUFFIX,ampproject.org,PROXY
DOMAIN-SUFFIX,openai.com,PROXY
DOMAIN-SUFFIX,openaiapi-site.azureedge.net,PROXY
DOMAIN-SUFFIX,sentry.io,PROXY
DOMAIN-SUFFIX,bing.com,PROXY
DOMAIN-SUFFIX,huggingface.co,PROXY
DOMAIN-SUFFIX,dapenti.com,PROXY
DOMAIN-SUFFIX,analysis.windows.net,DIRECT

' > Shadowrocket-ADBlock-Rules.cfg

cat /tmp/union.conf3 | egrep "^IP-CIDR.*,Reject$|^DOMAIN-SUFFIX.*,Reject$" >> Shadowrocket-ADBlock-Rules.cfg

echo '
GEOIP,CN,DIRECT
FINAL,PROXY

[URL Rewrite]
^http://(www.)?google.cn https://www.google.com 302
ctier=[A-Z] ctier=A 302
^https:\/\/[\s\S]*\.googlevideo\.com/.*&(oad|ctier) _ REJECT
' >> Shadowrocket-ADBlock-Rules.cfg

###
git status -s

git add .

git commit -a

git push
