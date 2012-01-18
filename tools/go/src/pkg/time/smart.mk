#
$(call go-new-module, time, pkg)

GOFILES=\
	format.go\
	sleep.go\
	tick.go\
	time.go\
	zoneinfo.go\

GOFILES_freebsd=\
	sys_unix.go\
	zoneinfo_unix.go\

GOFILES_darwin=\
	sys_unix.go\
	zoneinfo_unix.go\

GOFILES_linux=\
	sys_unix.go\
	zoneinfo_unix.go\

GOFILES_netbsd=\
	sys_unix.go\
	zoneinfo_unix.go\

GOFILES_openbsd=\
	sys_unix.go\
	zoneinfo_unix.go\

GOFILES_windows=\
	sys_windows.go\
	zoneinfo_windows.go\

GOFILES_plan9=\
	sys_plan9.go\
	zoneinfo_plan9.go\

sm.this.sources := $(GOFILES) $(GOFILES_$(GOOS))

$(go-build-this)
