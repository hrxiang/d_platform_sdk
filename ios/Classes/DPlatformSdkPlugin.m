#import "DPlatformSdkPlugin.h"
#import <flutter_dplatform_sdk/flutter_platform_sdk-Swift.h>

@implementation DPlatformSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftDPlatformSdkPlugin registerWithRegistrar:registrar];
}
@end
