
URL=http://sbc.io/hosts/alternates/fakenews-gambling-porn/hosts
wget $URL -O hosts

grep -v '#' hosts |awk  '{if(NF==2) print $2}' |grep "[a-z]" |awk -F"." '{if(NF>=2) print "DOMAIN-SUFFIX,"$(NF-1)"."$NF}' |sort -du  > fakenews-gambling-porn.list

rm -f hosts 2>/dev/null
