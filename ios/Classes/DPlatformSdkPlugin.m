#import "DPlatformSdkPlugin.h"
#import <d_platform_sdk/d_platform_sdk-Swift.h>

@implementation DPlatformSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftDPlatformSdkPlugin registerWithRegistrar:registrar];
}
@end
