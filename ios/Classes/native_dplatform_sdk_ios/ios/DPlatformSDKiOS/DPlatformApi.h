#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, Environment) {
    
    /// 测试环境.
    EnvironmentTest,
    
    /// 联调环境.
    EnvironmentDebug,
    
    /// 预生产环境.
    EnvironmentStage,
    
    /// 生产环境.
    EnvironmentProd,
};

@interface DPlatformApi : NSObject

/*!
 * @brief 注册URL Schemes.
 * @param env 当前环境.
 * @param station 站点名称.
 */
+ (void)registerAppWithEnv:(Environment)env station:(NSString *)station;

/*!
 * @brief 向 Wallet 发起请求 - 通用.
 * @param req key:value formatted.
 * @return YES/NO.
 */
+ (BOOL)sendReq:(NSDictionary *)req;

/*!
 * @brief 向 Wallet 发起请求 - 支付.
 * @param orderSn 平台接口产生的订单号.
 * @param token 接入方用户token.
 * @param channelNo 渠道号（可选）
 * @return YES/NO.
 */
+ (BOOL)sendPayReqWithOrderSn:(NSString *)orderSn token:(NSString *)token channelNo:(nullable NSString *)channelNo;

/*!
 * @brief 向 Wallet 发起请求 - 支付.
 * @param orderSn 平台接口产生的订单号.
 * @param token 接入方用户token.
 * @param extraParams 额外参数[key:value]（可选）
 * @return YES/NO.
 */
+ (BOOL)sendPayReqWithOrderSn:(NSString *)orderSn token:(NSString *)token extraParams:(nullable NSDictionary *)extraParams;

/*!
 * @brief 向 Wallet 发起请求 - 支付.
 * @param orderSn 平台接口产生的订单号.
 * @param outUid 接入方用户ID.
 * @param channelNo 渠道号.
 * @param extraParams 额外参数[key:value]（可选：mobileNo[接入方用户手机号码]）
 * @return YES/NO.
 */
+ (BOOL)sendPayReqWithOrderSn:(NSString *)orderSn outUid:(NSString *)outUid channelNo:(NSString *)channelNo extraParams:(nullable NSDictionary *)extraParams;

/*!
 * @brief   处理Wallet的回调.
 * @discuss 在AppDelegate -(application:openURL:options:)方法里调用.
 */
+ (BOOL)handleURL:(NSURL *)url result:(void(^)(NSDictionary *resp))result;
+ (BOOL)handleURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
