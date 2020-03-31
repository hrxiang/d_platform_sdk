package org.dplatform.utils;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.ActivityManager;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.net.Uri;

import java.util.List;

public class Utils {
    /**
     * 获取uri参数
     *
     * @param key uri参数里的key
     * @return uri参数里的value
     */
    public static String getUriParameterValue(Activity activity, String key) {
        Uri uri = getUri(activity);
        if (null != uri) {
            return uri.getQueryParameter(key);
        }
        return null;
    }

    public static Uri getUri(Activity activity) {
        if (null != activity) {
            return getUri(activity.getIntent());
        }
        return null;
    }

    public static Uri getUri(Intent intent) {
        if (null != intent) {
            return intent.getData();
        }
        return null;
    }

    /**
     * 唤起界面
     */
    public static void call(Activity activity, Uri uri, WithParameter parameter) {
        Intent intent = new Intent();
        intent.setData(uri);
        if (null != parameter) {
            parameter.with(intent);
        }
        activity.startActivity(intent);
    }


    public static boolean isInstalled(Context context, String packageName) {
        try {
            final PackageManager packageManager = context.getPackageManager();
            // 获取所有已安装程序的包信息
            List<PackageInfo> infoList = packageManager.getInstalledPackages(0);
            for (int i = 0; i < infoList.size(); i++) {
                if (infoList.get(i).packageName.equalsIgnoreCase(packageName))
                    return true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public static void openBrowser(Context context, String url) {
        Uri uri = Uri.parse(url);
        Intent intent = new Intent(Intent.ACTION_VIEW, uri);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);
    }

    public static boolean isRunningForeground(Context context) {
        ActivityManager activityManager = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
        if (null != activityManager) {
            List<ActivityManager.RunningAppProcessInfo> appProcessInfos = activityManager.getRunningAppProcesses();
            // 枚举进程
            for (ActivityManager.RunningAppProcessInfo appProcessInfo : appProcessInfos) {
                if (appProcessInfo.importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND) {
                    if (appProcessInfo.processName.equals(context.getApplicationInfo().processName)) {
                        return true;
                    }
                }
            }
        }
        return false;
    }

    @SuppressLint("MissingPermission")
    public static void moveTaskToFront(Context context, String packageName) {
        //如果APP是在后台运行
        if (!isRunningForeground(context)) {
            //获取ActivityManager
            ActivityManager activityManager = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
            if (null != activityManager) {
                //获得当前运行的task
                List<ActivityManager.RunningTaskInfo> taskList = activityManager.getRunningTasks(100);
                for (ActivityManager.RunningTaskInfo rti : taskList) {
                    //找到当前应用的task，并启动task的栈顶activity，达到程序切换到前台
                    if (rti.topActivity.getPackageName().equals(packageName)) {
                        activityManager.moveTaskToFront(rti.id, 0);
                        return;
                    }
                }
            }
        }

    }
}
