TARGET := iphone:clang:latest:14.0
ARCHS := arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = VideoStarCustomTool

VideoStarCustomTool_FILES = VideoStarCustomTool.m
VideoStarCustomTool_CFLAGS = -fobjc-arc
VideoStarCustomTool_FRAMEWORKS = UIKit Foundation PhotosUI CoreImage CoreGraphics

include $(THEOS_MAKE_PATH)/tweak.mk
