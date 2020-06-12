#import "DPlatformApi.h"

static Environment environment = EnvironmentProd;
static NSString *appStation;

///static NSString *baseUrlTest = @"http://172.29.24.139:8081/"; /* DEV */
static NSString *baseUrlTest = @"http://139.9.184.9/";
static NSString *baseUrlDebug = @"http://139.9.201.236/";
static NSString *baseUrlStage = @"https://dpl-pre.dpay.tech/";
static NSString *baseUrlProd = @"https://www.dpay.tech/";

static NSInteger loadingTag = 99231936;

static NSString *handleOpenUrlNotiKey = @"__dplatform_pro_handle_openurl__";

@implementation DPlatformApi

/*!
* @brief 通过站点名称构造钱包Scheme.
*/
+ (NSString *)genWalletScheme {
    return [NSString stringWithFormat:@"org.dplatform.lite.%@", appStation.lowercaseString];
}

/*!
* @brief 通过站点名称构造三方平台Scheme.
*/
+ (NSString *)genAppScheme {
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    return [NSString stringWithFormat:@"org.dplatform.game.%@.%@", appStation.lowercaseString, bundleId];
}

+ (NSString *)genBaseUrl {
    switch (environment) {
        case EnvironmentTest:
            return baseUrlTest;
        case EnvironmentDebug:
            return baseUrlDebug;
        case EnvironmentStage:
            return baseUrlStage;
        default:
            return baseUrlProd;
    }
}

/*!
* @brief 通过站点名称和当前环境构造钱包下载地址.
*/
+ (NSString *)genWalletDownloadUrl {
    NSString *baseUrl = [DPlatformApi genBaseUrl];
    switch (environment) {
        case EnvironmentTest:
            return [NSString stringWithFormat:@"%@%@", [baseUrl stringByAppendingString:@"appdownload/"], appStation.lowercaseString];
        case EnvironmentDebug:
            return [NSString stringWithFormat:@"%@%@", [baseUrl stringByAppendingString:@"appdownload/"], appStation.lowercaseString];
        case EnvironmentStage:
            return [NSString stringWithFormat:@"%@%@", [baseUrl stringByAppendingString:@"appdownload/"], appStation.lowercaseString];
        default:
            return [NSString stringWithFormat:@"%@%@", [baseUrl stringByAppendingString:@"appdownload/"], appStation.lowercaseString];
    }
}

/*!
 * @brief 注册URL Schemes.
 * @param env 当前环境.
 * @param station 站点名称.
 */
+ (void)registerAppWithEnv:(Environment)env station:(NSString *)station {
    NSAssert(station != NULL && station.length > 0, @"Station（站点名称）不能为空，请联系钱包方获取.");
    environment = env;
    appStation = station;
}

/*!
* @brief 向 Wallet 发起请求 - 通用.
* @param req key:value formatted.
* @return YES/NO.
*/
+ (BOOL)sendReq:(NSDictionary *)req {
    NSMutableDictionary *params = req.mutableCopy;
    [params setObject:[DPlatformApi genAppScheme] forKey:@"scheme"];

    NSString *paramsString = [DPlatformApi toJSONString:params];
    if (!paramsString) {
        return nil;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@://dplatform.org?params=%@", [DPlatformApi genWalletScheme], paramsString];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlString]]) {
        return [DPlatformApi openURL:[NSURL URLWithString:urlString]];
    } else {
        [DPlatformApi openURL:[NSURL URLWithString:[DPlatformApi genWalletDownloadUrl]]];
        return NO;
    }
}

/*!
 * @brief 向 Wallet 发起请求 - 支付.
 * @param orderSn 平台接口产生的订单号.
 * @param token 接入方用户token.
 * @param channelNo 渠道号（可选）
 * @return YES/NO.
 */
+ (BOOL)sendPayReqWithOrderSn:(NSString *)orderSn token:(NSString *)token channelNo:(nullable NSString *)channelNo {
    NSAssert(orderSn != NULL, @"The 'orderSn' could not be null.");
    NSAssert(token != NULL, @"The 'token' could not be null.");
    return [DPlatformApi sendPayReqWithOrderSn:orderSn token:token extraParams:@{
        @"channelNo": [NSString stringWithFormat:@"%@", channelNo]
    }];
}

/*!
 * @brief 向 Wallet 发起请求 - 支付.
 * @param orderSn 平台接口产生的订单号.
 * @param token 接入方用户token.
 * @param extraParams 额外参数[key:value]（可选）
 * @return YES/NO.
 */
+ (BOOL)sendPayReqWithOrderSn:(NSString *)orderSn token:(NSString *)token extraParams:(nullable NSDictionary *)extraParams {
    NSAssert(orderSn != NULL, @"The 'orderSn' could not be null.");
    NSMutableDictionary *prams = [NSMutableDictionary dictionaryWithDictionary:@{
        @"action": @"pay",
        @"orderSn": [NSString stringWithFormat:@"%@", orderSn],
        @"token": [NSString stringWithFormat:@"%@", token],
    }];
    if (extraParams) {
        [prams addEntriesFromDictionary:extraParams];
    }
    return [DPlatformApi sendReq:prams];
}

/*!
 * @brief 向 Wallet 发起请求 - 支付.
 * @param orderSn 平台接口产生的订单号.
 * @param outUid 接入方用户ID.
 * @param channelNo 渠道号.
 * @param extraParams 额外参数[key:value]（可选：mobileNo[接入方用户手机号码]）
 * @return YES/NO.
 */
+ (BOOL)sendPayReqWithOrderSn:(NSString *)orderSn outUid:(NSString *)outUid channelNo:(NSString *)channelNo extraParams:(nullable NSDictionary *)extraParams {
    NSAssert(orderSn != NULL, @"The 'orderSn' could not be null.");
    NSAssert(outUid != NULL, @"The 'outUid' could not be null.");
    NSAssert(channelNo != NULL, @"The 'channelNo' could not be null.");
    
    NSURL *url=[NSURL URLWithString:[[DPlatformApi genBaseUrl] stringByAppendingString:@"app/userCenter/security/createToken"]];
    NSMutableDictionary *reqParams = [NSMutableDictionary dictionaryWithDictionary:@{
        @"channelNo": channelNo,
        @"outUid": outUid
    }];
    if (extraParams) {
        [reqParams addEntriesFromDictionary:extraParams];
    }
    
    [DPlatformApi showLoading];
    [DPlatformApi asyncPostReqWithUrl:url params:reqParams completion:^(NSDictionary *resp) {
        
        [DPlatformApi removeLoading];
        if (![resp isKindOfClass:[NSDictionary class]]) return;
        
        NSString *code = [NSString stringWithFormat:@"%@", resp[@"respCode"]];
        NSString *token = [NSString stringWithFormat:@"%@", resp[@"data"]];
        if (![@"000000" isEqualToString:code]) {
            [DPlatformApi showAlert:[NSString stringWithFormat:@"Failed to fetch the token: %@", [DPlatformApi jsonStrConvertByObject:resp]]];
            return;
        }
        
        [DPlatformApi sendPayReqWithOrderSn:orderSn token:token extraParams:@{
            @"channelNo": channelNo
        }];
    }];
    return YES;
}

/**!
 * @brief obj->JSON String.
 */
+ (NSString *)toJSONString:(id)obj {
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:obj options:0 error:&error];
    if (!error){
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return nil;
}

/**!
 * @brief Open URL.
 */
+ (BOOL)openURL:(NSURL *)url {
    if([[UIApplication sharedApplication] canOpenURL:url]) {
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:url];
        }
        return YES;
    }
    return NO;
}

/**
 * @brief Open URL截取URL中的参数.
 */
+ (NSMutableDictionary *)getURLParameters:(NSString *)parameterString {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if ([parameterString containsString:@"&"]) {
        NSArray *urlComponents = [parameterString componentsSeparatedByString:@"&"];
        for (NSString *keyValuePair in urlComponents) {
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
            NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];

            if (key == nil || value == nil) {
                continue;
            }
            [params setValue:value forKey:key];
        }
        
    } else {
        NSArray *pairComponents = [parameterString componentsSeparatedByString:@"="];
        if (pairComponents.count == 1) {
            return nil;
        }
        NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
        NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];
        if (key == nil || value == nil) {
            return nil;
        }
        [params setValue:value forKey:key];
        
    }
    return params;
    
}

/*!
 * @brief 处理Wallet的回调.
 * @discuss 在AppDelegate -(application:openURL:options:)方法里调用.
 */
+ (BOOL)handleURL:(NSURL *)url result:(void(^)(NSDictionary *resp))result {
    if ([url.scheme isEqualToString:[DPlatformApi genWalletScheme]]) {
        NSDictionary *resp = [DPlatformApi respWithURL:url];
        if (resp) {
            [[NSNotificationCenter defaultCenter] postNotificationName:handleOpenUrlNotiKey object:resp];
            result(resp);
            return YES;
        }
    }
    return NO;
}

+ (BOOL)handleURL:(NSURL *)url {
    return [DPlatformApi handleURL:url result:^(NSDictionary * _Nonnull resp) {}];
}

/*!
* @brief 解析回调URL.
*/
+ (NSDictionary *)respWithURL:(NSURL *)url {
    NSString *query = [url.query stringByRemovingPercentEncoding] ?: @"";
    NSDictionary *paramDict = [DPlatformApi getURLParameters:query];
    return paramDict;
}

/*!
* @brief ---------------------------------------------- Utils ----------------------------------------------
*/
+ (id)objectConvertByJsonStr:(NSString *)jsonStr {
  NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
  NSError *error;
  id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
  if (error) {
      NSLog(@"[%s]error:%@", __func__, error);
  }
  return obj;
}

+ (NSString *)jsonStrConvertByObject:(id)obj {
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingSortedKeys error:&error];
    if (error) {
        NSLog(@"[%s]error:%@", __func__, error);
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (void)asyncPostReqWithUrl:(NSURL *)url params:(NSDictionary *)params completion:(void(^)(NSDictionary *resp))completion {
    NSString *paramsJson = [DPlatformApi jsonStrConvertByObject:params];
    NSData *paramsData = [paramsJson dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:300];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:@{
        @"Content-Type": @"application/json;charset=UTF-8"
    }];
    [request setHTTPBody:paramsData];
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *responseText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"url:\n%@\nparams:\n%@\nresp:%@", url.absoluteURL, paramsJson, responseText);
        
        id resp = [DPlatformApi objectConvertByJsonStr:responseText];
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(resp);
            });
        }
    }];
    [dataTask resume];
}

+ (void)showAlert:(NSString *)message {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:NULL message:[NSString stringWithFormat:@"%@", message] preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}]];
    [[DPlatformApi keyWindow].rootViewController presentViewController:controller animated:true completion:^{}];
}

+ (UIWindow *)keyWindow {
    UIWindow *window = nil;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *windowScene in [UIApplication sharedApplication].connectedScenes) {
            if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                window = windowScene.windows.firstObject;
                break;
            }
        }
    } else {
        window = [UIApplication sharedApplication].keyWindow;
    }
    return window;
}

+ (void)showLoading {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        view.tag = loadingTag;
        view.backgroundColor = UIColor.blackColor;
        view.alpha = 0;
        
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
        indicator.center = view.center;
        indicator.color = UIColor.whiteColor;
        [indicator startAnimating];
        [view addSubview:indicator];
        [[DPlatformApi keyWindow] addSubview:view];
        
        [UIView animateWithDuration:0.2 animations:^{
            view.alpha = 0.5f;
        }];
    });
}

+ (void)removeLoading {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *view = [[DPlatformApi keyWindow] viewWithTag:loadingTag];
        if (!view) return;
        [UIView animateWithDuration:0.2 animations:^{
            view.alpha = 0;
        } completion:^(BOOL finished) {
            [view removeFromSuperview];
        }];
    });
}

@end
