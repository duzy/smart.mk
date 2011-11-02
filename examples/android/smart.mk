#
#
$(call sm-new-module, native-activity, shared, android-ndk)
$(call sm-use, android_native_app_glue)

sm.this.verbose := true
sm.this.sources := na.c
sm.this.libs := log android EGL GLESv1_CM

$(sm-build-this)

define dump
$(info $(strip $1): $($(strip $1)))
endef #dump

$(call dump, TOOLCHAIN_PREFIX)
$(call dump, NDK_ROOT)
$(call dump, NDK_PLATFORMS_ROOT)
$(call dump, NDK_TOOLCHAIN)
$(call dump, NDK_TOOLCHAIN_PREFIX)
$(call dump, NDK_ALL_PLATFORMS)
$(call dump, NDK_ALL_PLATFORM_LEVELS)
$(call dump, NDK_MAX_PLATFORM_LEVEL)
$(call dump, NDK_ALL_ABIS)
$(foreach abi, $(NDK_ALL_ABIS), $(call dump,NDK_ABI.$(abi).toolchains))
$(call dump, NDK_ALL_TOOLCHAINS)
$(foreach tc, $(NDK_ALL_TOOLCHAINS), $(call dump,NDK_TOOLCHAIN.$(tc).abis))
$(foreach tc, $(NDK_ALL_TOOLCHAINS), $(call dump,NDK_TOOLCHAIN.$(tc).setup))