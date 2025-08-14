# Theos bootstrap
THEOS ?= $(HOME)/theos
export THEOS

ARCHS = arm64
TARGET := iphone:clang:latest:14.0
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

SUBPROJECTS += SongShank
SUBPROJECTS += SongShankPrefs

# Explicit include (don’t rely on THEOS_MAKE_PATH here)
include $(THEOS)/makefiles/aggregate.mk
