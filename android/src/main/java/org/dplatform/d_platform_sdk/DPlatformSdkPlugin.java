package org.dplatform.d_platform_sdk;

import android.app.Activity;
import android.content.Intent;

import org.dplatform.sdk.DPlatformApi;
import org.dplatform.sdk.DPlatformApiCallback;
import org.dplatform.sdk.DPlatformApiFactory;
import org.dplatform.sdk.DPlatformEvn;
import org.json.JSONObject;

import java.util.Map;
import java.util.Set;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.PluginRegistry;


public class DPlatformSdkPlugin implements MethodCallHandler, PluginRegistry.NewIntentListener, DPlatformApiCallback {
    private Activity activity;
    private static MethodChannel channel;
    private DPlatformApi api;

    private DPlatformSdkPlugin(Activity activity) {
        this.activity = activity;
    }

    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        try {
            if ("init".equals(methodCall.method)) {
                if (methodCall.arguments instanceof Map) {
                    String site = methodCall.argument("site");
                    Integer index = methodCall.argument("env");
                    System.out.println("DPlatformSdkPlugin==========init=====" + site + "|" + index);
                    if (null != site) {
                        api = DPlatformApiFactory.createApi(activity, site, getPlatformEvn(index));
                    }
                }

            } else if ("call".equals(methodCall.method)) {
                if (null != api) {
                    if (methodCall.arguments() instanceof Map) {
                        Map<String, Object> params = methodCall.arguments();
                        Set<String> keys = params.keySet();
                        for (String key : keys) {
                            api.putParameter(key, params.get(key));
                        }
                    }
                    api.sendReq();
                }
            } else if ("listener".equals(methodCall.method)) {
                System.out.println("DPlatformSdkPlugin============onCreate method===============");
                if (null != api) {
                    api.setCallback(this);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void registerWith(PluginRegistry.Registrar registrar) {
        DPlatformSdkPlugin plugin = new DPlatformSdkPlugin(registrar.activity());
        // 注册onNewIntent
        registrar.addNewIntentListener(plugin);
        // 创建通道
        channel = new MethodChannel(registrar.messenger(), "d_platform_sdk");
        channel.setMethodCallHandler(plugin);
    }

    @Override
    public boolean onNewIntent(Intent intent) {
        System.out.println("DPlatformSdkPlugin============onNewIntent method===============");
        if (null != api) {
            api.onNewIntent(intent);
        }
        return false;
    }

    @Override
    public void onResult(JSONObject object) {
        channel.invokeMethod("listener", object.toString());
    }

    private static DPlatformEvn getPlatformEvn(Integer index) {
        DPlatformEvn evn;
        if (null == index) index = 0;
        switch (index) {
            case 0:
                evn = DPlatformEvn.DEBUG;
                break;
            case 1:
                evn = DPlatformEvn.TEST;
                break;
            case 2:
                evn = DPlatformEvn.PRO;
                break;
            default:
                evn = DPlatformEvn.RELEASE;
                break;
        }
        return evn;
    }
}


