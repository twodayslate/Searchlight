TARGET=:clang
ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk

BUNDLE_NAME = ListLauncherPref
ListLauncherPref_FILES = ListLauncherPref.mm
ListLauncherPref_INSTALL_PATH = /Library/PreferenceBundles
ListLauncherPref_FRAMEWORKS = UIKit
ListLauncherPref_PRIVATE_FRAMEWORKS = Preferences
ListLauncherPref_ARCHS = armv7 arm64

#export SYSROOT = /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS7.0.sdk

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/ListLauncherPref.plist$(ECHO_END)
