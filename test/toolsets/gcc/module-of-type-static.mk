#
#
####
test.case.module-of-type-static-mk-loaded := 1
####
THIS_MAKEFILE := $(lastword $(MAKEFILE_LIST))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
$(call test-check-undefined, sm.this.dir)
$(call test-check-module-empty, sm.this)
########## case in -- make a new module
$(call sm-new-module, module-of-type-static, gcc: static)
########## case out
$(call test-check-value-of,sm.this.dir,$(THIS_DIR))
$(call test-check-value-of,sm.this.makefile,$(THIS_MAKEFILE))
$(call test-check-value-of,sm.this.suffix,.a)
$(call test-check-value-of,sm.this.toolset,gcc)
$(call test-check-value-of,sm.this.toolset.args,static)

sm.this.sources := foo.c foo.go bar.c

sm.this.export.libdirs := $(sm.out.lib)
sm.this.export.libs := $(sm.this.name)

$(call test-check-undefined,sm.module.module-of-type-static.name)
########## case in -- build module
$(sm-build-this)
########## case out
$(call test-check-value-of,sm.module.module-of-type-static.name,module-of-type-static)