# d_platform_sdk

A new Flutter plugin.

## Getting Started

 1， call其他app并传递数据
   DPlatformSdk.call(
     "d_platform_sdk_test2://login",
      "login",
       "org.dplatform.d_platform_sdk_test",
                    params: {
                      "userId": "1234567",
                    },
                    downloadUrl: "www.360.com",
                );