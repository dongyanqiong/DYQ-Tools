#!/bin/bash
do_swap () {
  SUM=0
  OVERALL=0
  for DIR in `find /proc/ -maxdepth 1 -type d | egrep "^/proc/[0-9]"` ; do
    PID=`echo $DIR | cut -d / -f 3`
    PROGNAME=`ps -p $PID -o comm --no-headers`
    for SWAP in `grep Swap $DIR/smaps 2>/dev/null| awk '{ print $2 }'`
    do
      SUM=$(($SUM+$SWAP))
    done
    echo "PID=$PID - Swap used: $SUM - $PROGNAME"
    OVERALL=$(($OVERALL+$SUM))
    SUM=0 
  done
  echo "Overall swap used: $OVERALL KB."
 }
do_swap > tmp.txt
cat tmp.txt |awk -F[\ \(] '{print $5"\t KB",$1"\t",$7}' | sort -n | tail -10
cat tmp.txt |tail -1
rm -rf tmp.txt