TARGET=:clang
ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk

BUNDLE_NAME = searchlightpreferences
searchlightpreferences_FILES = ListLauncherPref.mm LLAboutController.mm LLFavoritesController.mm LLRecentController.mm LLApplicationController.mm LLAppearanceController.mm
searchlightpreferences_INSTALL_PATH = /Library/PreferenceBundles
searchlightpreferences_FRAMEWORKS = UIKit
searchlightpreferences_PRIVATE_FRAMEWORKS = Preferences
searchlightpreferences_LIBRARIES = applist
searchlightpreferences_ARCHS = armv7 arm64

#export SYSROOT = /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS7.0.sdk

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/searchlightpreferences.plist$(ECHO_END)
