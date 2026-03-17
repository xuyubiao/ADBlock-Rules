
URL=http://sbc.io/hosts/alternates/fakenews-gambling-porn/hosts
wget $URL -O hosts

grep -v '#' hosts |awk  '{if(NF==2) print $2}' |grep "[a-z]" |awk -F"." '{if(NF>=2) print "DOMAIN-SUFFIX,"$(NF-1)"."$NF}' |grep "[a-z]" |sort -du  > fakenews-gambling-porn.list

rm -f hosts 2>/dev/null

######################################################
GFW=https://raw.githubusercontent.com/gfwlist/gfwlist/master/list.txt
wget $GFW -O list.txt

egrep -v '@|!|http:|/' list.txt | sed -E 's#^\|{1,2}(https://)?##' |grep "[a-z]" |awk -F"." '{if(NF>=2) print "DOMAIN-SUFFIX,"$(NF-1)"."$NF}' |grep "[a-z]" |sort -du > gwlist.txt

rm -f list.txt 2>/dev/null

