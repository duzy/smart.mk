# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_TEMP/feature-compile-sources-flags-in-file/compile.flags.0.c
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_TEMP/feature-compile-sources-flags-in-file/compile.flags.1.c
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_TEMP/feature-compile-sources-flags-in-file/compile.flags.2.c
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/features/feature-compile-sources-flags-in-file/foobar.c.o
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/features/feature-compile-sources-flags-in-file/foobar.c.d
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/features/feature-compile-sources-flags-in-file/foo.c.o
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/features/feature-compile-sources-flags-in-file/foo.c.d
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/features/feature-compile-sources-flags-in-file/bar.c.o
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/features/feature-compile-sources-flags-in-file/bar.c.d
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_BIN/feature-compile-sources-flags-in-file$EXE

out=`$OUT_BIN/feature-compile-sources$EXE`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "smart.test.foo: foo;smart.test.bar: bar;"

out=`cat $OUT_TEMP/feature-compile-sources-flags-in-file/compile.flags.0.c`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "-g -ggdb -DTEST=\\\"foobar\\\""

out=`cat $OUT_TEMP/feature-compile-sources-flags-in-file/compile.flags.1.c`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "-g -ggdb -DTEST=\\\"foo\\\""

out=`cat $OUT_TEMP/feature-compile-sources-flags-in-file/compile.flags.2.c`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "-g -ggdb -DTEST=\\\"bar\\\""
