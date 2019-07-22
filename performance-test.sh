#!/usr/bin/env bash
SHOPURL=${SHOPURL-localhost:8080}
NUM_REQUESTS=${NUM_REQUESTS:-300}
CONCURRENCY=${CONCURRENCY:-5}
VERBOSITY='-v 0'

# this is pvc (tmp/data) and git repo (performanceresults)
OUT_DIR=/tmp/data/performanceresults/`date +%Y-%m-%d-%H-%M-%S`
mkdir -p ${OUT_DIR}

bold=$(tput bold)
normal=$(tput sgr0)

echo "${bold}POST 200 /messaging/${normal}"

ab ${VERBOSITY} -n ${NUM_REQUESTS} -c ${CONCURRENCY} -H "Content-Type: application/json"  -H "Accept: application/json" -T 'application/json' -g ${OUT_DIR}/messaging-200.out -p messaging-200 "http://${SHOPURL}/messaging" 2>&1 | tee ${OUT_DIR}/messaging-200.ab

# generate plot data
cd ${OUT_DIR}
ls *.out | sed -e "s/.out//" > list
for i in `cat list` ; do
   sed -e "s/INPUTFILE/$i/" -e "s/OUTPUTFILE/$i/" \
   /home/mike/git/quarkus-coffeeshop-demo/plot.gnu | gnuplot
done
rm list

exit 0
