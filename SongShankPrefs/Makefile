export THEOS=/var/theos
ARCHS = arm64
TARGET := iphone:clang:latest:14.0
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = SongShankPrefs
SongShankPrefs_FILES = SongShankPrefs.mm
SongShankPrefs_INSTALL_PATH = /Library/PreferenceBundles
SongShankPrefs_FRAMEWORKS = UIKit
SongShankPrefs_PRIVATE_FRAMEWORKS = Preferences
SongShankPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp -a layout/Library/PreferenceLoader/Preferences/SongShankPrefs.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/$(ECHO_END)
