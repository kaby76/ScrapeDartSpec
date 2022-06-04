#!/bin/sh

rm -rf reference
mkdir reference
mkdir reference/Java
cp ../sdk/tools/spec_parser/Dart.g reference/Dart.g4
cp ../sdk/tools/spec_parser/Dart.g reference/Java/SpecParser.java
pushd reference
trgen -t Java -s libraryDefinition
cd Generated
make
popd

ok=0
total=0
for i in `find ../sdk/sdk/lib/ -name '*.dart'`
do
echo -n "$i "
pushd ./reference/Generated > /dev/null 2>&1
make run RUNARGS="-file ../../$i" > /dev/null 2>&1
x=$?
popd > /dev/null 2>&1
echo $x
if [ $x = 0 ]
then
ok=`expr $ok + 1`
fi
total=`expr $total + 1`
done

echo Number of passed tests $ok
echo Total parsed $total
