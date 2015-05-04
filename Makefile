THEOS_DEVICE_IP = 127.0.0.1
THEOS_DEVICE_PORT = 2222

THEOS_PACKAGE_DIR_NAME = debs
TARGET := iphone:clang
ARCHS := armv7 arm64

include theos/makefiles/common.mk

TWEAK_NAME = Searchlight
Searchlight_FILES = Tweak.xm
Searchlight_FRAMEWORKS = UIKit QuartzCore CoreGraphics
Searchlight_PRIVATE_FRAMEWORKS = Preferences
Searchlight_LIBRARIES = applist

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += searchlightpreferences

include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 SpringBoard"
