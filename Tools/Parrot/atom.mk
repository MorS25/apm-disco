LOCAL_PATH := $(call my-dir)

ifneq ("$(V)","0")
APM_VERBOSE=-vv
else
APM_VERBOSE=
endif

###############################################################################
# APM:Plane, for disco
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := apm-plane-disco
LOCAL_MODULE_FILENAME := $(LOCAL_MODULE).done
LOCAL_DESCRIPTION := APM:Plane is an open source autopilot
LOCAL_CATEGORY_PATH := $(APM_COMMON_CATEGORY_PATH)

APM_PLANE_DISCO_BUILD_DIR := $(call local-get-build-dir)
APM_PLANE_DISCO_SRC_DIR := $(LOCAL_PATH)/../..

APM_PLANE_DISCO_WAF_FLAGS := \
	--top=$(APM_PLANE_DISCO_SRC_DIR) \
	--out=$(APM_PLANE_DISCO_BUILD_DIR) \
	--no-submodule-update \
	$(APM_VERBOSE)

$(APM_PLANE_DISCO_BUILD_DIR)/$(LOCAL_MODULE_FILENAME):PRIVATE_APM_PLANE_DISCO_BUILD_DIR=$(APM_PLANE_DISCO_BUILD_DIR)
$(APM_PLANE_DISCO_BUILD_DIR)/$(LOCAL_MODULE_FILENAME):PRIVATE_APM_PLANE_DISCO_SRC_DIR=$(APM_PLANE_DISCO_SRC_DIR)
$(APM_PLANE_DISCO_BUILD_DIR)/$(LOCAL_MODULE_FILENAME):
	@echo "Building APM for Disco"
	$(Q) (cd $(PRIVATE_APM_PLANE_DISCO_SRC_DIR); \
		git submodule init; \
		git submodule update modules/waf modules/mavlink)
	$(Q) TARGET_CROSS=$(TARGET_CROSS) \
	CFLAGS="$(TARGET_CFLAGS) -DPLOP" \
	CXXFLAGS="$(TARGET_CXXFLAGS) -DTATA" \
	LDFLAGS="$(TARGET_LDFLAGS) -static" \
	$(PRIVATE_APM_PLANE_DISCO_SRC_DIR)/modules/waf/waf-light \
		configure \
		$(APM_PLANE_DISCO_WAF_FLAGS) \
		--board=disco --prefix=$(TARGET_OUT_STAGING)/usr \
		--disable-lttng \
		--disable-libiio \
		--notests;
	$(PRIVATE_APM_PLANE_DISCO_SRC_DIR)/modules/waf/waf-light \
		$(APM_PLANE_DISCO_WAF_FLAGS) \
		--targets bin/arduplane
	$(Q) mv $(PRIVATE_APM_PLANE_DISCO_BUILD_DIR)/disco/bin/arduplane \
		$(TARGET_OUT_STAGING)/usr/bin/apm-plane-disco
	@touch $@

LOCAL_CLEAN_FILES := $(TARGET_OUT_STAGING)/usr/bin/apm-plane-disco

LOCAL_COPY_FILES = \
	50-apm-plane-disco.rc:etc/boxinit.d/ \
	../Frame_params/Parrot_Disco.param:etc/arduplane/disco.parm

include $(BUILD_CUSTOM)

