#
#
####
test.case.module-of-type-shared-mk-loaded := 1
####
THIS_MAKEFILE := $(lastword $(MAKEFILE_LIST))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
$(call test-check-undefined, sm.this.dir)
########## case in -- make a new module
$(call sm-new-module, module-of-type-shared, gcc: shared)
########## case out
$(call test-check-value-of,sm.this.dir,$(THIS_DIR))
$(call test-check-value-of,sm.this.makefile,$(THIS_MAKEFILE))
$(call test-check-value-of,sm.this.suffix,.so)
$(call test-check-value-of,sm.this.toolset,gcc)
$(call test-check-value-of,sm.this.toolset.args,shared)

sm.this.sources := foo.c foo.go
sm.this.compile.flags += -fPIC

sofilename := $(sm.out.bin)/$(sm.this.name)$(sm.this.suffix)
sm.this.export.libs := $(sofilename)

$(call test-check-undefined,sm.module.module-of-type-shared.name)
########## case in -- build module
$(sm-build-this)
########## case out
$(call test-check-value-of,sm.module.module-of-type-shared.name,module-of-type-shared)
$(call test-check-value-of,sm.module.module-of-type-shared.export.libs,$(sofilename))
