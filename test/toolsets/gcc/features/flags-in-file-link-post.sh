# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/intermediates/feature-flags-in-file-link/toolsets/gcc/features/main.c.o
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/intermediates/feature-flags-in-file-link/toolsets/gcc/features/main.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/temp/feature-flags-in-file-link/flags.link.0

out=`test-readfile $TOP/out/gcc/debug/temp/feature-flags-in-file-link/flags.link.0`
test-check-value-contains ${BASH_SOURCE}:${LINENO} "$out" "-O2"
#test-check-value ${BASH_SOURCE}:${LINENO} "$out" "-Wl,--no-undefined -O2"

