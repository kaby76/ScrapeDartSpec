#!/bin/sh

ok=0
total=0
for i in `find ../../flutter -name '*.dart'`
do
    date
    echo $i
    java -classpath "c:/users/kenne/downloads/antlr-4.8-complete.jar;." SpecParser $i
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

# Fails
# 'required'
# ../../flutter/dev/benchmarks/macrobenchmarks/lib/src/color_filter_and_fade.dart
# ../../flutter/dev/benchmarks/macrobenchmarks/lib/src/web/bench_simple_lazy_text_scroll.dart
# ../../flutter/dev/benchmarks/macrobenchmarks/lib/src/web/bench_text_layout.dart
# ../../flutter/dev/benchmarks/macrobenchmarks/lib/src/web/recorder.dart
# ../../flutter/dev/benchmarks/macrobenchmarks/lib/src/web/test_data.dart
# ../../flutter/dev/benchmarks/microbenchmarks/lib/common.dart
# ../../flutter/dev/benchmarks/platform_views_layout_hybrid_composition/lib/android_platform_view.dart
# ../../flutter/dev/benchmarks/test_apps/stocks/lib/stock_types.dart
# ../../flutter/dev/bots/service_worker_test.dart
# ../../flutter/dev/bots/test.dart
# ../../flutter/dev/devicelab/bin/tasks/ios_app_with_extensions_test.dart
# ../../flutter/dev/devicelab/lib/framework/ab.dart
# ../../flutter/dev/devicelab/lib/framework/adb.dart
# ../../flutter/dev/devicelab/lib/framework/browser.dart
# ../../flutter/dev/devicelab/lib/framework/manifest.dart
# ../../flutter/dev/devicelab/lib/framework/utils.dart
# ../../flutter/dev/devicelab/lib/tasks/web_benchmarks.dart
# ../../flutter/dev/integration_tests/flutter_driver_screenshot_test/lib/page.dart
# ../../flutter/dev/integration_tests/hybrid_android_views/lib/android_platform_view.dart
# ../../flutter/dev/manual_tests/lib/actions.dart


