set terminal png
set output "OUTPUTFILE.png"
set title 'OUTPUTFILE'
set xlabel "request"
set ylabel "ms"
plot "INPUTFILE.out" using 7 with lines title "ctime", \
"INPUTFILE.out" using 8 with lines title "dtime", \
"INPUTFILE.out" using 9  with lines title "ttime", \
"INPUTFILE.out" using 10 with lines title "wait"
