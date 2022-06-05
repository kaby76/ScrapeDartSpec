#!/bin/sh

if [[ ! -d test ]]
then
	mkdir test
fi

cd test

if [[ ! -d sdk ]]
then
	git clone --depth 1 --filter=blob:none --no-checkout https://github.com/dart-lang/sdk.git
	pushd sdk
	git checkout main -- sdk/lib
	popd
fi

if [[ ! -d grammars-v4 ]]
then
	git clone --depth 1 --filter=blob:none --no-checkout https://github.com/antlr/grammars-v4.git
	pushd grammars-v4
	git checkout master -- dart2
	cd dart2
	trgen
	cd Generated
	make
	popd
fi

ok=0
total=0
for i in `find ./sdk/sdk/lib/ -name '*.dart'`
do
	echo -n "$i "
	./grammars-v4/dart2/Generated/bin/Debug/net6.0/Test.exe -file $i > /dev/null 2>&1
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
