TARGET := iphone:clang:latest:7.0

include $(THEOS)/makefiles/common.mk

TOOL_NAME = soper

soper_FILES = main.m
soper_CFLAGS = -fobjc-arc
soper_CODESIGN_FLAGS = -Sentitlements.plist
soper_INSTALL_PATH = /usr/local/bin

include $(THEOS_MAKE_PATH)/tool.mk
