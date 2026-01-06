package io.flutter.plugins;

import android.Manifest;
import android.app.ActivityManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Environment;
import android.text.TextUtils;
import android.util.Log;
import android.widget.Toast;

import androidx.core.app.ActivityCompat;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Random;

import android.provider.Settings;

import com.tencent.vasdolly.helper.ChannelReaderUtil;

public class DeviceUtils {
    private static final String TAG = "DeviceUtils";
    private static final String DEVICE_ID_FILE = ".bili_id.txt";
    private static final String DEFAULT_ACTIVITY = "MainActivity";
    
    /**
     * 获取设备唯一标识
     * 优先级：SD卡存储的ID > Android ID > 生成的随机ID
     */
    public static String getUniqueId(Context context) {
        String deviceId = "";
        try {
            File currentFile = new File(getRootDir(context), DEVICE_ID_FILE);
            if (currentFile.exists()) {
                deviceId = getFileContent(currentFile);
            }
            
            if (isInvalidDeviceId(deviceId)) {
                deviceId = getAndroidId(context);
                saveIdToFile(deviceId, currentFile);
            }
            
            if (isInvalidDeviceId(deviceId)) {
                deviceId = generateDeviceId();
                saveIdToFile(deviceId, currentFile);
            }
        } catch (Exception e) {
            Log.e(TAG, "获取设备ID失败", e);
        }
        return deviceId;
    }

    /**
     * 设置设备唯一标识
     */
    public static String setUniqueId(String deviceId, Context context) {
        try {
            File currentFile = new File(getRootDir(context), DEVICE_ID_FILE);
            saveIdToFile(deviceId, currentFile);
        } catch (Exception e) {
            Log.e(TAG, "设置设备ID失败", e);
        }
        return deviceId;
    }

    private static boolean isInvalidDeviceId(String deviceId) {
        return TextUtils.isEmpty(deviceId) || deviceId.contains("00000000000000");
    }

    private static void saveIdToFile(String deviceId, File file) throws IOException {
        if (!file.exists()) {
            file.createNewFile();
        }
        try (FileOutputStream fos = new FileOutputStream(file)) {
            fos.write(deviceId.getBytes());
        }
    }

    /**
     * 获取渠道号
     */
    public static String getChannel(Context context) {
        return ChannelReaderUtil.getChannel(context);
    }

    private static String getFileContent(File file) {
        try (FileInputStream inputStream = new FileInputStream(file)) {
            byte[] buffer = new byte[512];
            int length = inputStream.read(buffer);
            return new String(buffer, 0, length);
        } catch (IOException e) {
            Log.e(TAG, "读取文件失败", e);
            return "";
        }
    }

    private static String getAndroidId(Context context) {
        return Settings.System.getString(context.getContentResolver(), Settings.System.ANDROID_ID);
    }

    private static String generateDeviceId() {
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMddHHmmssS");
        String dateStr = dateFormat.format(System.currentTimeMillis());
        return "A" + getRandomString(2) + dateStr;
    }

    private static String getRootDir(Context context) {
        if (Environment.getExternalStorageState().equals(Environment.MEDIA_MOUNTED)) {
            return Environment.getExternalStorageDirectory().getAbsolutePath();
        }
        return context.getCacheDir().getAbsolutePath();
    }

    /**
     * 生成随机字符串
     */
    public static String getRandomString(int length) {
        String str = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
        Random random = new Random();
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < length; i++) {
            sb.append(str.charAt(random.nextInt(52)));
        }
        return sb.toString();
    }

    /**
     * 切换应用图标
     * @param context 上下文
     * @param iconName 图标名称（default/aiqiyi/deepseek/bili）
     */
    public static void changeIcon(Context context, String iconName) {
        if (context == null) {
            Log.e(TAG, "Context不能为空");
            return;
        }

        PackageManager packageManager = context.getPackageManager();
        String packageName = context.getPackageName();
        
        // 获取当前Activity的类名
        String currentActivityName = getCurrentActivityName(context);
        if (currentActivityName == null) {
            Log.e(TAG, "无法获取当前Activity类名");
            return;
        }

        // 构建所有图标的ComponentName
        ComponentName defaultIcon = new ComponentName(packageName, currentActivityName);
        ComponentName aiqiyiIcon = new ComponentName(packageName, currentActivityName.replace(DEFAULT_ACTIVITY, "IconAiQiYi"));
        ComponentName deepseekIcon = new ComponentName(packageName, currentActivityName.replace(DEFAULT_ACTIVITY, "IconDeepSeek"));
        ComponentName biliIcon = new ComponentName(packageName, currentActivityName.replace(DEFAULT_ACTIVITY, "IconBili"));

        // 禁用所有图标
        disableAllIcons(packageManager, defaultIcon, aiqiyiIcon, deepseekIcon, biliIcon);

        // 启用指定图标
        enableSelectedIcon(packageManager, iconName, defaultIcon, aiqiyiIcon, deepseekIcon, biliIcon);
    }

    /**
     * 获取当前Activity的类名
     */
    private static String getCurrentActivityName(Context context) {
        try {
            ActivityManager activityManager = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
            if (activityManager == null) {
                return null;
            }

            List<ActivityManager.RunningTaskInfo> runningTasks = activityManager.getRunningTasks(1);
            if (runningTasks != null && !runningTasks.isEmpty()) {
                ComponentName componentName = runningTasks.get(0).topActivity;
                return componentName != null ? componentName.getClassName() : null;
            }
        } catch (SecurityException e) {
            Log.e(TAG, "获取当前Activity类名失败", e);
        }
        return null;
    }

    /**
     * 禁用所有图标
     */
    private static void disableAllIcons(PackageManager packageManager, ComponentName... icons) {
        for (ComponentName icon : icons) {
            try {
                packageManager.setComponentEnabledSetting(
                    icon,
                    PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                    PackageManager.DONT_KILL_APP
                );
            } catch (Exception e) {
                Log.e(TAG, "禁用图标失败: " + icon.getClassName(), e);
            }
        }
    }

    /**
     * 启用选定的图标
     */
    private static void enableSelectedIcon(PackageManager packageManager, String iconName,
                                         ComponentName defaultIcon, ComponentName aiqiyiIcon,
                                         ComponentName deepseekIcon, ComponentName biliIcon) {
        ComponentName targetIcon = defaultIcon;
        switch (iconName) {
            case "aiqiyi":
                targetIcon = aiqiyiIcon;
                break;
            case "deepseek":
                targetIcon = deepseekIcon;
                break;
            case "bili":
                targetIcon = biliIcon;
                break;
            default:
                break;
        }

        try {
            packageManager.setComponentEnabledSetting(
                targetIcon,
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                PackageManager.DONT_KILL_APP
            );
        } catch (Exception e) {
            Log.e(TAG, "启用图标失败: " + targetIcon.getClassName(), e);
        }
    }
}

