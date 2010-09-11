#

$(call sm-check-not-empty,sm.top)
$(call sm-check-not-empty,sm.this.toolset,smart: Must set 'sm.this.toolset')

ifeq ($(strip $(sm.this.sources)$(sm.this.sources.external)),)
  $(error smart: no sources for module '$(sm.this.name)')
endif

##################################################

ifeq ($(sm.this.type),t)
 $(if $(sm.this.lang),,$(error smart: 'sm.this.lang' must be defined for tests module))
endif

define sm.code.check-infile
ifeq ($$(call is-true,$$(sm.this.$1.flags.infile)),true)
  ifeq ($$(sm.this.$1.options.infile),)
    sm.this.$1.options.infile := true
  else
    $$(error smart: 'sm.this.$1.options.infile' and 'sm.this.$1.flags.infile' mismatched)
  endif
endif
endef #sm.code.check-infile

$(foreach a,compile archive link,$(eval $(call sm.code.check-infile,$a)))

##################################################

sm.var.build_action.static := archive
sm.var.build_action.shared := link
sm.var.build_action.exe := link
sm.var.build_action.t := link

##########

## Empty compile options for all langs
$(foreach sm._var._temp._lang,$(sm.tool.$(sm.this.toolset).langs),\
  $(eval sm.var.$(sm.this.name).compile.options.$(sm._var._temp._lang) := )\
  $(eval sm.var.$(sm.this.name).compile.options.$(sm._var._temp._lang).defined := ))

sm.var.$(sm.this.name).archive.options :=
sm.var.$(sm.this.name).archive.options.defined :=
sm.var.$(sm.this.name).link.options :=
sm.var.$(sm.this.name).link.options.defined :=
sm.var.$(sm.this.name).link.libs :=
sm.var.$(sm.this.name).link.libs.defined :=

## eg. $(call sm.code.append-list,RESULT_VAR_NAME,LIST,PREFIX,SUFFIX)
define sm.code.append-list
 $(foreach sm._var._temp._item,$(strip $2),\
     $(eval $(strip $1) += $(strip $3)$(sm._var._temp._item:$(strip $3)%$(strip $4)=%)$(strip $4)))
endef #sm.code.append-list

##
define sm.code.switch-options-into-file
$(if $(call is-true,$(sm.this.$1.options.infile)),\
     $$(call sm-util-mkdir,$(sm.out.tmp)/$(sm.this.name))\
     $$(eval sm.var.$(sm.this.name).$1.options$2 := $$(subst \",\\\",$$(sm.var.$(sm.this.name).$1.options$2)))\
     $$(shell echo $$(sm.var.$(sm.this.name).$1.options$2) > $(sm.out.tmp)/$(sm.this.name)/$1.options$2)\
     $$(eval sm.var.$(sm.this.name).$1.options$2 := @$(sm.out.tmp)/$(sm.this.name)/$1.options$2))
endef #sm.code.switch-options-into-file

##
define sm.code.calculate-compile-options
 sm.var.$(sm.this.name).compile.options.$1.defined := true
 sm.var.$(sm.this.name).compile.options.$1 := $(if $(call equal,$(sm.this.type),t),-x$(sm.this.lang))\
  $(strip $(sm.global.compile.flags) $(sm.global.compile.options)) \
  $(strip $(sm.global.compile.flags.$1) $(sm.global.compile.options.$1)) \
  $(strip $(sm.this.compile.flags) $(sm.this.compile.options)) \
  $(strip $(sm.this.compile.flags.$1) $(sm.this.compile.options.$1))
 $$(call sm.code.append-list, sm.var.$(sm.this.name).compile.options.$1, $(sm.global.includes), -I)
 $$(call sm.code.append-list, sm.var.$(sm.this.name).compile.options.$1, $(sm.this.includes), -I)
 $(call sm.code.switch-options-into-file,compile,.$1)
endef #sm.code.calculate-compile-options

##
define sm.code.calculate-link-options
 sm.var.$(sm.this.name).link.options.defined := true
 sm.var.$(sm.this.name).link.options := \
  $(strip $(sm.global.link.flags) $(sm.global.link.options)) \
  $(strip $(sm.this.link.flags) $(sm.this.link.options))
 $(if $(call equal,$(sm.this.type),shared),\
     $$(if $$(filter -shared,$$(sm.var.$(sm.this.name).link.options)),,\
        $$(eval sm.var.$(sm.this.name).link.options += -shared)))
 $(call sm.code.switch-options-into-file,link)
endef #sm.code.calculate-link-options

## TODO: archive options infile support
define sm.code.calculate-archive-options
 sm.var.$(sm.this.name).archive.options.defined := true
 sm.var.$(sm.this.name).archive.options := \
  $(strip $(sm.global.archive.flags) $(sm.global.archive.options)) \
  $(strip $(sm.this.archive.flags) $(sm.this.archive.options))
 $(call sm.code.switch-options-into-file,archive)
endef #sm.code.calculate-archive-options

##
define sm.code.calculate-link-libs
 sm.var.$(sm.this.name).link.libs.defined := true
 sm.var.$(sm.this.name).link.libs :=
 $$(call sm.code.append-list, sm.var.$(sm.this.name).link.libs, $(sm.global.libdirs), -L)
 $$(call sm.code.append-list, sm.var.$(sm.this.name).link.libs, $(sm.this.libdirs), -L)
 $$(call sm.code.append-list, sm.var.$(sm.this.name).link.libs, $(sm.global.libs), -l)
 $$(call sm.code.append-list, sm.var.$(sm.this.name).link.libs, $(sm.this.libs), -l)
 $(if $(call is-true,$(sm.this.link.options.infile)),\
     $$(call sm-util-mkdir,$(sm.out.tmp)/$(sm.this.name))\
     $$(eval sm.var.$(sm.this.name).link.libs := $$(subst \",\\\",$$(sm.var.$(sm.this.name).link.libs)))\
     $$(shell echo $$(sm.var.$(sm.this.name).link.libs) > $(sm.out.tmp)/$(sm.this.name)/link.libs)\
     $$(eval sm.var.$(sm.this.name).link.libs := @$(sm.out.tmp)/$(sm.this.name)/link.libs))
endef #sm.code.calculate-link-libs

## TODO: something like switch-objects-into-file for linking and archiving

$(call sm-check-defined,sm.code.calculate-compile-options,\
       smart: 'sm.code.calculate-compile-options' not defined)
$(call sm-check-defined,sm.code.calculate-archive-options,\
       smart: 'sm.code.calculate-archive-options' not defined)
$(call sm-check-defined,sm.code.calculate-link-options,\
       smart: 'sm.code.calculate-link-options' not defined)
$(call sm-check-defined,sm.code.calculate-link-libs,\
       smart: 'sm.code.calculate-link-libs' not defined)

define sm.fun.$(sm.this.name).calculate-compile-options
$(if $(sm.var.$(sm.this.name).compile.options.$1.defined),,\
   $(eval $(call sm.code.calculate-compile-options,$1)))
endef #sm.fun.$(sm.this.name).calculate-compile-options

define sm.fun.$(sm.this.name).calculate-archive-options
 $(if $(sm.var.$(sm.this.name).archive.options.defined),,\
   $(eval $(call sm.code.calculate-archive-options)))
endef #sm.fun.$(sm.this.name).calculate-archive-options

define sm.fun.$(sm.this.name).calculate-link-options
 $(if $(sm.var.$(sm.this.name).link.options.defined),,\
   $(eval $(call sm.code.calculate-link-options)))
endef #sm.fun.$(sm.this.name).calculate-link-options

define sm.fun.$(sm.this.name).calculate-link-libs
 $(if $(sm.var.$(sm.this.name).link.libs.defined),,\
   $(eval $(call sm.code.calculate-link-libs)))
endef #sm.fun.$(sm.this.name).calculate-link-libs

##################################################

$(call sm-check-not-empty,sm.this.dir)

## The output object file prefix
sm._var._temp._object_prefix := \
  $(call sm-to-relative-path,$(sm.out.obj))$(sm.this.dir:$(sm.top)%=%)

##
##
define sm.fun.calculate-object.
$(sm._var._temp._object_prefix)/$(basename $(subst ..,_,$(call sm-to-relative-path,$1))).o
endef #sm.fun.calculate-object.

define sm.fun.calculate-object.external
$(call sm.fun.calculate-object.,$1)
endef #sm.fun.calculate-object.external

##
## source file of relative location
define sm.fun.calculate-source.
$(call sm-to-relative-path,$(sm.this.dir)/$(strip $1))
endef #sm.fun.calculate-source.

##
## source file of fixed location
define sm.fun.calculate-source.external
$(call sm-to-relative-path,$(strip $1))
endef #sm.fun.calculate-source.external

##
## binary module to be built
define sm.fun.calculate-exe-module-targets
$(call sm-to-relative-path,$(sm.out.bin))/$(sm.this.name)$(sm.this.suffix)
endef #sm.fun.calculate-exe-module-targets

define sm.fun.calculate-t-module-targets
$(call sm-to-relative-path,$(sm.out.bin))/$(sm.this.name)$(sm.this.suffix)
endef #sm.fun.calculate-t-module-targets

define sm.fun.calculate-shared-module-targets
$(call sm-to-relative-path,$(sm.out.bin))/$(sm.this.name)$(sm.this.suffix)
endef #sm.fun.calculate-shared-module-targets

define sm.fun.calculate-static-module-targets
$(call sm-to-relative-path,$(sm.out.lib))/lib$(sm.this.name:lib%=%)$(sm.this.suffix)
endef #sm.fun.calculate-static-module-targets

##################################################

## Make rule for building object
##   eg. $(call sm.fun.make-object-rule, c++, foobar.cpp)
##   eg. $(call sm.fun.make-object-rule, c++, ~/sources/foobar.cpp, external)
define sm.fun.make-object-rule
 $(if $1,,$(error smart: arg \#1 must be the lang type))\
 $(if $2,,$(error smart: arg \#2 must be the source file))\
 $(if $3,$(call sm-check-equal,$(strip $3),external,smart: arg \#3 must be 'external' if specified))\
 $(call sm-check-defined,sm.fun.calculate-source.$(strip $3),\
     smart: donot know how to calculate sources of lang '$(strip $1)$(if $3,($(strip $3)))')\
 $(call sm-check-defined,sm.fun.calculate-object.$(strip $3),\
     smart: donot know how to calculate objects of lang '$(strip $1)$(if $3,($(strip $3)))')\
 $(call sm-check-defined,sm.fun.$(sm.this.name).calculate-compile-options,\
     smart: no callback for getting compile options of lang '$(strip $1)')\
 $(eval sm._var._temp._object := $(call sm.fun.calculate-object.$(strip $3),$2))\
 $(eval sm.var.$(sm.this.name).objects += $(sm._var._temp._object))\
 $(if $(call is-true,$(sm.this.gen_deps)),\
      $(eval sm._var._temp._depend := $(sm._var._temp._object:%.o=%.d))\
      $(eval sm.var.$(sm.this.name).depends += $(sm._var._temp._depend))\
      $(eval include $(sm._var._temp._depend))\
      $(call sm.rule.dependency.$(strip $1),\
         $(sm._var._temp._depend),$(sm._var._temp._object),\
         $(call sm.fun.calculate-source.$(strip $3),$2),\
         sm.var.$(sm.this.name).compile.options.$(strip $1)))\
 $(call sm.fun.$(sm.this.name).calculate-compile-options,$(strip $1))\
 $(call sm.rule.compile.$(strip $1),\
    $(sm._var._temp._object),\
    $(call sm.fun.calculate-source.$(strip $3),$2),\
    sm.var.$(sm.this.name).compile.options.$(strip $1))
endef #sm.fun.make-object-rule

##
## Produce code for make object rules
define sm.code.make-rules
$(if $1,,$(error smart: arg \#1 must be lang-type))\
$(if $(sm.tool.$(sm.this.toolset).$1.suffix),,$(error smart: no registered suffixes for $(sm.this.toolset)/$1))\
 sm._var._temp._suffix.$1 := $$(sm.tool.$(sm.this.toolset).$1.suffix:%=\%%)
 sm.this.sources.$1 := $$(filter $$(sm._var._temp._suffix.$1),$$(sm.this.sources))
 sm.this.sources.external.$1 := $$(filter $$(sm._var._temp._suffix.$1),$$(sm.this.sources.external))
 sm.this.sources.has.$1 := $$(if $$(sm.this.sources.$1)$$(sm.this.sources.external.$1),true,)
 ifeq ($$(sm.this.sources.has.$1),true)
  $$(call sm-check-flavor, sm.fun.make-object-rule, recursive)
  $$(foreach s,$$(sm.this.sources.$1),$$(call sm.fun.make-object-rule,$1,$$s))
  $$(foreach s,$$(sm.this.sources.external.$1),$$(call sm.fun.make-object-rule,$1,$$s,external))
 endif
endef #sm.code.make-rules

##
## Make object rules, eg. $(call sm.fun.make-rules,c++)
define sm.fun.make-rules
$(eval $(call sm.code.make-rules,$(strip $1)))
endef #sm.fun.make-rules

##
## Make module build rule
define sm.fun.make-module-rule
$(if $(sm.var.$(sm.this.name).objects),\
    $(call sm-check-defined,sm.fun.calculate-$(sm.this.type)-module-targets)\
    $(eval sm.var.$(sm.this.name).targets := $(strip $(call sm.fun.calculate-$(sm.this.type)-module-targets)))\
    $(call sm-check-defined,sm.var.build_action.$(sm.this.type))\
    $(call sm-check-defined,sm.var.$(sm.this.name).lang)\
    $(call sm-check-defined,sm.rule.$(sm.var.build_action.$(sm.this.type)).$(sm.var.$(sm.this.name).lang))\
    $(call sm.fun.$(sm.this.name).calculate-$(sm.var.build_action.$(sm.this.type))-options)\
    $(call sm.fun.$(sm.this.name).calculate-$(sm.var.build_action.$(sm.this.type))-libs)\
    $(call sm-check-defined,sm.var.$(sm.this.name).$(sm.var.build_action.$(sm.this.type)).options)\
    $(if $(call equal,$(sm.this.type),static),,\
      $(call sm-check-defined,sm.var.$(sm.this.name).$(sm.var.build_action.$(sm.this.type)).libs))\
    $(call sm-check-not-empty,sm.var.$(sm.this.name).lang)\
    $(call sm.rule.$(sm.var.build_action.$(sm.this.type)).$(sm.var.$(sm.this.name).lang),\
       $$(sm.var.$(sm.this.name).targets),\
       $$(sm.var.$(sm.this.name).objects),\
       sm.var.$(sm.this.name).$(sm.var.build_action.$(sm.this.type)).options,\
       $(if $(call equal,$(sm.this.type),static),,\
         sm.var.$(sm.this.name).$(sm.var.build_action.$(sm.this.type)).libs)),\
  $(error smart: No objects for building '$(sm.this.name)'))
endef #sm.fun.make-module-rule

##################################################

sm.var.$(sm.this.name).targets :=
sm.var.$(sm.this.name).objects :=
sm.var.$(sm.this.name).depends :=

## Make object rules for sources of different lang
$(foreach sm._var._temp._lang,$(sm.tool.$(sm.this.toolset).langs),\
  $(call sm.fun.make-rules,$(sm._var._temp._lang))\
  $(if $(sm.var.$(sm.this.name).lang),,\
    $(if $(sm.this.sources.has.$(sm._var._temp._lang)),\
         $(eval sm.var.$(sm.this.name).lang := $(sm._var._temp._lang)))))

ifeq ($(sm.this.type),t)
  sm.this.sources.$(sm.this.lang).t := $(filter %.t,$(sm.this.sources))
  sm.this.sources.external.$(sm.this.lang).t := $(filter %.t,$(sm.this.sources.external))
  sm.this.sources.has.$(sm.this.lang).t := $(if $(sm.this.sources.$(sm.this.lang).t)$(sm.this.sources.external.$(sm.this.lang).t),true)
  ifeq ($(or $(sm.this.sources.has.$(sm.this.lang)),$(sm.this.sources.has.$(sm.this.lang).t)),true)
    $(call sm-check-flavor, sm.fun.make-object-rule, recursive)
    $(foreach t,$(sm.this.sources.$(sm.this.lang).t),$(call sm.fun.make-object-rule,$(sm.this.lang),$t))
    $(foreach t,$(sm.this.sources.external.$(sm.this.lang).t),$(call sm.fun.make-object-rule,$(sm.this.lang),$t,external))
    ifeq ($(sm.var.$(sm.this.name).lang),)
      sm.var.$(sm.this.name).lang := $(sm.this.lang)
    endif
  endif
endif

## Make rule for targets of the module
$(call sm.fun.make-module-rule)

# ifeq ($(strip $(sm.this.sources.c)$(sm.this.sources.c++)$(sm.this.sources.asm)),)
#   $(error smart: internal error: sources mis-calculated)
# endif

ifeq ($(strip $(sm.var.$(sm.this.name).targets)),)
  $(error smart: internal error: targets mis-calculated)
endif

ifeq ($(strip $(sm.var.$(sm.this.name).objects)),)
  $(error smart: internal error: objects mis-calculated)
endif

sm.this.targets = $(sm.var.$(sm.this.name).targets)
sm.this.objects = $(sm.var.$(sm.this.name).objects)
sm.this.depends = $(sm.var.$(sm.this.name).depends)

##################################################

$(call sm-check-not-empty, sm.tool.common.rm)
$(call sm-check-not-empty, sm.tool.common.rmdir)

sm.rules.phony.* += \
  clean-$(sm.this.name) \
  clean-$(sm.this.name)-target \
  clean-$(sm.this.name)-targets \
  clean-$(sm.this.name)-objects \
  clean-$(sm.this.name)-depends

clean-$(sm.this.name): \
  clean-$(sm.this.name)-targets \
  clean-$(sm.this.name)-objects \
  clean-$(sm.this.name)-depends
	@echo "'$(@:clean-%=%)' is cleaned."

clean-$(sm.this.name)-target:; $(info smart: do you mean $@s?) @false

define sm.code.make-clean-rules
  clean-$(sm.this.name)-targets:
	$(if $(call is-true,$(sm.this.verbose)),,$$(info remove:$(sm.var.$(sm.this.name).targets))@)$$(call sm.tool.common.rm,$$(sm.var.$(sm.this.name).targets))
  clean-$(sm.this.name)-objects:
	$(if $(call is-true,$(sm.this.verbose)),,$$(info remove:$(sm.var.$(sm.this.name).objects))@)$$(call sm.tool.common.rm,$$(sm.var.$(sm.this.name).objects))
  clean-$(sm.this.name)-depends:
	$(if $(call is-true,$(sm.this.verbose)),,$$(info remove:$(sm.var.$(sm.this.name).depends))@)$$(call sm.tool.common.rm,$$(sm.var.$(sm.this.name).depends))
endef #sm.code.make-clean-rules

$(eval $(sm.code.make-clean-rules))

##################################################
