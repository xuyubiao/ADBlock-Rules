wget https://raw.githubusercontent.com/StevenBlack/hosts/refs/heads/master/alternates/fakenews-gambling-porn-only/hosts
grep -v '#' hosts |awk  '{if(NF==2) print $2}' |awk -F"." '{if(NF>=2) print "DOMAIN-SUFFIX,"$(NF-1)"."$NF}' |sort -du  > fakenews-gambling-porn.list
