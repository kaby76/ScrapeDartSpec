#!/bin/sh

ok=0
total=0
for i in `find ../flutter -name '*.dart'`
do
date
echo $i
./bin/Debug/netcoreapp3.1/ScrapeDartSpec.exe $i > /dev/null 2>&1
x=$?
echo $x
if [ $x = 0 ]
then
ok=`expr $ok + 1`
fi
total=`expr $total + 1`
date
done

echo Number of passed tests $ok
echo Total parsed $total
