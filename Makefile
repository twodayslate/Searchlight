THEOS_DEVICE_IP = 192.168.0.101

THEOS_PACKAGE_DIR_NAME = debs
TARGET := iphone:clang
ARCHS := armv7 arm64

include theos/makefiles/common.mk

TWEAK_NAME = ListLauncher7
ListLauncher7_FILES = Tweak.xm
ListLauncher7_FRAMEWORKS = UIKit
ListLauncher7_LIBRARIES = applist

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
