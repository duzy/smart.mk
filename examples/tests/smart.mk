#

$(call sm-new-module, foo, tests)
$(call sm-check-not-empty,sm.this.dir)
$(call sm-check-not-empty,sm.this.type)
$(call sm-check-not-empty,sm.this.name)
$(call sm-check-not-empty,sm.this.suffix)
$(call sm-check-not-empty,sm.this.makefile)
$(call sm-check-in-list,foo,sm.global.modules)
$(call sm-check-equal,$(sm.this.name),foo)
$(call sm-check-equal,$(sm.this.type),t)
$(call sm-check-equal,$(sm.this.suffix),$(if $(sm.os.name.win32),.test.exe,.test))

## Turn on verbose to make command lines visible
sm.this.verbose := true

## Test module must specify this
sm.this.lang := c

sm.this.toolset := gcc

sm.this.sources := foobar.t

sm.this.compile.flags := -DTEST=\"$(sm.this.name)\"

sm.this.includes := $(sm.this.dir)/../include

sm.this.link.flags := --subsystem=console

sm.this.libdirs := $(sm.this.dir)/../libs

sm.this.libs := 

$(sm-build-this)
