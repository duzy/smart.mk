#
#
$(call test-check-module-empty, sm.this)
$(call test-check-module-empty, sm.module.toolset_go_package)
$(call sm-new-module, toolset_go_package, go: package)

sm.this.sources := foo.go foo.c
sm.this.export.compile.flags := -I$(sm.out.lib)
sm.this.export.link.flags := -L$(sm.out.lib)

$(sm-build-this)