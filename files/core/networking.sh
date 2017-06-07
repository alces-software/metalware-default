#!/bin/bash
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <%=jobid%>
#Cluster: <%=cluster%>

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $BASEDIR/config

run_script network-base.sh
run_script network-ipmi.sh

for n in $_ALCES_NETWORKS; do
  export _ALCES_NET=$n
  run_script network-join.sh
done

