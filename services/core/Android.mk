LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := services.core

LOCAL_AIDL_INCLUDES := system/netd/server/binder

LOCAL_SRC_FILES += \
    $(call all-java-files-under,java) \
    $(call all-proto-files-under, proto) \
    java/com/android/server/EventLogTags.logtags \
    java/com/android/server/am/EventLogTags.logtags \
    ../../../../system/netd/server/binder/android/net/INetd.aidl \
    ../../../../system/netd/server/binder/android/net/metrics/INetdEventListener.aidl \
    ../../../native/cmds/installd/binder/android/os/IInstalld.aidl \

LOCAL_AIDL_INCLUDES += \
    system/netd/server/binder

LOCAL_PROTOC_OPTIMIZE_TYPE := nano

LOCAL_JAVA_LIBRARIES := \
    services.net \
    android.hidl.manager-V1.0-java \

LOCAL_STATIC_JAVA_LIBRARIES := \
    time_zone_distro \
    time_zone_distro_installer \
    android.hidl.base-V1.0-java-static \
    android.hardware.tetheroffload.control-V1.0-java-static \

ifneq ($(INCREMENTAL_BUILDS),)
    LOCAL_PROGUARD_ENABLED := disabled
    LOCAL_JACK_ENABLED := incremental
endif

LOCAL_JACK_FLAGS := \
 -D jack.transformations.boost-locked-region-priority=true \
 -D jack.transformations.boost-locked-region-priority.classname=com.android.server.am.ActivityManagerService \
 -D jack.transformations.boost-locked-region-priority.request=com.android.server.am.ActivityManagerService\#boostPriorityForLockedSection \
 -D jack.transformations.boost-locked-region-priority.reset=com.android.server.am.ActivityManagerService\#resetPriorityAfterLockedSection

LOCAL_JAR_PROCESSOR := lockedregioncodeinjection
# Use = instead of := to delay evaluation of ${in} and ${out}
LOCAL_JAR_PROCESSOR_ARGS = \
 --targets \
  "Lcom/android/server/am/ActivityManagerService;,Lcom/android/server/wm/WindowHashMap;" \
 --pre \
  "com/android/server/am/ActivityManagerService.boostPriorityForLockedSection,com/android/server/wm/WindowManagerService.boostPriorityForLockedSection" \
 --post \
  "com/android/server/am/ActivityManagerService.resetPriorityAfterLockedSection,com/android/server/wm/WindowManagerService.resetPriorityAfterLockedSection" \
 -o ${out} \
 -i ${in}

include $(BUILD_STATIC_JAVA_LIBRARY)
