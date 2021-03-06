#

$(call sm-new-module, foo, static, gcc)

$(call sm-check-not-empty,sm.this.dir)
$(call sm-check-not-empty,sm.this.name)
$(call sm-check-not-empty,sm.this.suffix)
$(call sm-check-not-empty,sm.this.makefile)
$(call sm-check-in-list,foo,sm.global.modules)
$(call sm-check-equal,$(sm.this.name),foo)
$(call sm-check-equal,$(sm.this.type),static)
$(call sm-check-equal,$(sm.this.suffix),.a)

## Turn on verbose to make command lines visible
sm.this.verbose ?= true

## The flags to be used by the compiler
sm.this.compile.flags := -DTEST=\"$(sm.this.name)\"

## The include search path (for compiler's -I switch), each item of this will
## be translated into a -I switch for the compiler by the toolset.
sm.this.includes := $(sm.this.dir)/../include
sm.this.sources := foobar.c

sm.this.link.flags := $(if $(sm.os.name.win32),--subsystem=console)

# TODO: ignore this and make a warning for static module
sm.this.libdirs := $(sm.this.dir)/../libs

# TODO: ignore this for static module
sm.this.libs := 

$(sm-build-this)
