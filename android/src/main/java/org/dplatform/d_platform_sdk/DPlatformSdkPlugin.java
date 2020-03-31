package org.dplatform.d_platform_sdk;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;

import org.dplatform.utils.Utils;
import org.dplatform.utils.WithParameter;
import org.jetbrains.annotations.NotNull;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.PluginRegistry;


public class DPlatformSdkPlugin implements MethodCallHandler, PluginRegistry.NewIntentListener {
    private Activity activity;
    private static MethodChannel channel;

    private DPlatformSdkPlugin(Activity activity) {
        this.activity = activity;
    }

    @Override
    public void onMethodCall(@NotNull MethodCall methodCall, @NotNull MethodChannel.Result result) {
        try {
            if ("call".equals(methodCall.method)) {
                if (methodCall.arguments() instanceof Map) {
                    Map<String, String> map = methodCall.arguments();
                    String urlString = map.remove("urlString");
                    String packageName = map.remove("packageName");
                    String downloadUrl = map.remove("downloadUrl");
                    if (null != packageName) {
                        boolean isInstalled = Utils.isInstalled(activity, packageName);
                        if (isInstalled) {
                            if (null != urlString) {
                                Uri.Builder builder = Uri.parse(urlString).buildUpon();
                                for (String key : map.keySet()) {
                                    builder.appendQueryParameter(key, map.get(key));
                                }
                                Utils.call(activity, builder.build(), new WithParameter() {
                                    @Override
                                    public void with(Intent intent) {
                                        intent.setAction(Intent.ACTION_VIEW);
                                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                                    }
                                });
                            }
                        } else {
                            if (null != downloadUrl) {
                                Utils.openBrowser(activity, downloadUrl);
                            }
                        }
                    }
                }
            } else if ("listener".equals(methodCall.method)) {
                send(Utils.getUri(activity));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void registerWith(PluginRegistry.Registrar registrar) {
        channel = new MethodChannel(registrar.messenger(), "d_platform_sdk");
        channel.setMethodCallHandler(new DPlatformSdkPlugin(registrar.activity()));
    }

    @Override
    public boolean onNewIntent(Intent intent) {
        send(Utils.getUri(intent));
        return false;
    }

    private static void send(Uri uri) {
        if (null != uri) {
            Set<String> keys = uri.getQueryParameterNames();
            Map<String, String> arguments = new HashMap<>();
            if (null != keys) {
                String value;
                for (String key : keys) {
                    value = uri.getQueryParameter(key);
                    if (null != value) {
                        arguments.put(key, value);
                    }
                }
            }
            channel.invokeMethod("listener", arguments);
        }
    }
}


