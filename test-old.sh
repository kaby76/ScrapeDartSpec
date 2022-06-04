#!/bin/sh

rm -rf reference
mkdir reference
cp -r ~/g-current/grammars-v4/dart2/* reference/
pushd reference
trgen
cd Generated
make
popd

ok=0
total=0
for i in `find ../sdk/sdk/lib/ -name '*.dart'`
do
echo -n "$i "
./reference/Generated/bin/Debug/net6.0/Test.exe -file $i > /dev/null 2>&1
x=$?
echo $x
if [ $x = 0 ]
then
ok=`expr $ok + 1`
fi
total=`expr $total + 1`
done

echo Number of passed tests $ok
echo Total parsed $total
