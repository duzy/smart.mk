define test-check-defined
$(eval \
  ifeq ($(strip $1),)
    $$(error test-check-defined: arg 1 is empty)
  endif
  ifndef $(strip $1)
    $$(error "$(strip $1)" is undefined)
  endif
 )
endef #test-check-defined

define test-check-undefined
$(eval \
  ifeq ($(strip $1),)
    $$(error test-check-defined: arg 1 is empty)
  endif
  ifdef $(strip $1)
    $$(error "$(strip $1)" is defined)
  endif
 )
endef #test-check-undefined

define test-check-flavor
$(eval \
  ifneq ($(flavor $(strip $1)),$(strip $2))
    $$(error "$$$$(flavor $(strip $1))" != "$(strip $2)")
  endif
 )
endef #test-check-flavor

define test-check-origin
$(eval #
  ifneq ($(origin $(strip $1)),$(strip $2))
    $$(error "$$$$(origin $(strip $1))" != "$(strip $2)")
  endif
 )
endef #test-check-origin

define test-check-value-of
$(eval \
  ifeq ($(strip $1),)
    $$(error test-check-value: arg 1 is empty)
  endif
  ifndef $(strip $1)
    $$(error "$(strip $1)" is undefined)
  endif
  ifneq ($($(strip $1)),$2)
    $$(error $$$$($(strip $1)) != "$2", ("$($(strip $1))"))
  endif
 )
endef #test-check-value-of

define test-check-value-pat-of
$(eval \
  ifeq ($(strip $1),)
    $$(error test-check-value: arg 1 is empty)
  endif
  ifndef $(strip $1)
    $$(error "$(strip $1)" is undefined)
  endif
  ifneq ($(words $($(strip $1))),1)
    $$(error $$$$(words $$$$($(strip $1))) != 1)
  endif
  ifeq ($(filter $2,$($(strip $1))),)
    $$(error $$$$($(strip $1)) != "$2", ("$($(strip $1))"))
  endif
 )
endef #test-check-value-pat-of

define test-check-value
$(eval \
  ifneq ($1,$2)
    $$(error "$1" != "$2")
  endif
 )
endef #test-check-value

define test-check-not-value
$(eval \
  ifeq ($1,$2)
    $$(error "$1" == "$2")
  endif
 )
endef #test-check-not-value

define test-check-value-pat
$(eval \
  ifneq ($(words $1),1)
    $$(error $$$$(words $1) != 1)
  endif
  ifeq ($(filter $2,$1),)
    $$(error "$1" != "$2")
  endif
 )
endef #test-check-value-pat

define test-foreach-module-prop
$(eval \
  MOD := $(strip $1)
  FUN := $(strip $2)
 )\
$(eval \
  PROPS := $(filter $(MOD).%, $(.VARIABLES))
 )\
$(foreach PROP, $(PROPS), $($(FUN)))
endef #test-foreach-module-prop

define test-check-prop-empty
$(eval \
  ifdef $(PROP)
    $$(error test: "$(PROP)" is not empty: "$($(PROP))")
  endif
 )
endef #test-check-prop-empty

define test-check-module-empty
$(call test-foreach-module-prop, $1, test-check-prop-empty)
endef #test-check-module-empty
