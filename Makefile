# --- Theos bootstrap (edit THEOS if installed elsewhere) ---
THEOS ?= $(HOME)/theos
export THEOS

ARCHS = arm64
TARGET := iphone:clang:latest:14.0
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

SUBPROJECTS += SongShank
SUBPROJECTS += SongShankPrefs

# Explicit include so it never resolves to /aggregate.mk
include $(THEOS)/makefiles/aggregate.mk
