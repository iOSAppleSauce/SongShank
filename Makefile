export THEOS=/var/theos
ARCHS = arm64
TARGET := iphone:clang:latest:14.0
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

SUBPROJECTS += SongShank
SUBPROJECTS += SongShankPrefs

include $(THEOS_MAKE_PATH)/aggregate.mk
