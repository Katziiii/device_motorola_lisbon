#
# Copyright (C) 2025 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := $(call my-dir)

ifeq ($(TARGET_DEVICE),lisbon)
include $(call all-makefiles-under,$(LOCAL_PATH))

# Directories we want to ensure exist
VENDOR_SYMLINK_DIRS := \
    $(TARGET_OUT_VENDOR)/lib \
    $(TARGET_OUT_VENDOR)/lib64 \
    $(TARGET_OUT_VENDOR)/lib/hw \
    $(TARGET_OUT_VENDOR)/lib64/hw

# src:dst relative to vendor root
SYMLINK_LIST := \
    vendor/lib/mt6785/libdpframework.so:lib/libdpframework.so \
    vendor/lib/mt6785/libmtk_drvb.so:lib/libmtk_drvb.so \
    vendor/lib64/mt6785/libdpframework.so:lib64/libdpframework.so \
    vendor/lib64/mt6785/libmtk_drvb.so:lib64/libmtk_drvb.so \
    vendor/lib/mt6785/libpq_prot.so:lib/libpq_prot.so \
    vendor/lib64/mt6785/libpq_prot.so:lib64/libpq_prot.so \
    vendor/lib/hw/libMcGatekeeper.so:lib/hw/gatekeeper.trustonic.so \
    vendor/lib/hw/libSoftGatekeeper.so:lib/hw/gatekeeper.default.so \
    vendor/lib64/hw/libMcGatekeeper.so:lib64/hw/gatekeeper.trustonic.so \
    vendor/lib64/hw/libSoftGatekeeper.so:lib64/hw/gatekeeper.default.so \
    vendor/lib/egl/libGLES_mali.so:lib/hw/vulkan.mt6785.so \
    vendor/lib64/egl/libGLES_mali.so:lib64/hw/vulkan.mt6785.so \
    vendor/lib/hw/kmsetkey.trustonic.so:lib/hw/kmsetkey.default.so \
    vendor/lib64/hw/kmsetkey.trustonic.so:lib64/hw/kmsetkey.default.so \
    vendor/lib/mt6785/libnir_neon_driver.so:lib/libnir_neon_driver.so \
    vendor/lib64/mt6785/libmcv_runtime.mtk.so:lib64/libmcv_runtime.mtk.so \
    vendor/lib64/mt6785/libneuron_runtime.5.so:lib64/libneuron_runtime.5.so \
    vendor/lib64/mt6785/libneuron_runtime.so:lib64/libneuron_runtime.so \
    vendor/lib64/mt6785/libnir_neon_driver.so:lib64/libnir_neon_driver.so

# Symlink generation rule
$(VENDOR_SYMLINK_DIRS): $(LOCAL_INSTALLED_MODULE)
	$(hide) echo ">>> Creating vendor symlinks"
	@mkdir -p $(VENDOR_SYMLINK_DIRS)
	$(foreach l,$(SYMLINK_LIST), \
		src=$(firstword $(subst :, ,$(l))); \
		dst=$(lastword $(subst :, ,$(l))); \
		echo "  Symlink: $$src -> $(TARGET_OUT_VENDOR)/$$dst"; \
		ln -sf ../../$${src} $(TARGET_OUT_VENDOR)/$${dst};)

	$(hide) touch $@

ALL_DEFAULT_INSTALLED_MODULES += $(VENDOR_SYMLINK_DIRS)

endif
