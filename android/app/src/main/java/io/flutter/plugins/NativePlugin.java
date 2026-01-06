package io.flutter.plugins;

import android.app.Activity;

import android.util.Log;

import java.util.Objects;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
// import com.jaeger.library.StatusBarUtil;

//本地插件
public class NativePlugin implements MethodChannel.MethodCallHandler {

    public static String CHANNEL = "com.insert/device";

    static MethodChannel methodChannel;

    private Activity activity;

    private NativePlugin(Activity activity) {
        this.activity = activity;
    }

    /// 注册
    public static void registerWith(FlutterActivity flutterActivity, FlutterEngine engine) {
        methodChannel = new MethodChannel(engine.getDartExecutor().getBinaryMessenger(), CHANNEL);
        NativePlugin instance = new NativePlugin(flutterActivity);
        methodChannel.setMethodCallHandler(instance);
    }

    /// 调用
    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        if (call.method.equals("getDeviceId")) {
            result.success(DeviceUtils.getUniqueId(activity));
        } else if (call.method.equals("setDeviceId")) {
            result.success(DeviceUtils.setUniqueId(call.argument("uuid"), activity));
        } else if (call.method.equals("getMimeType")) {
            result.success(FileUtils.getMimeType(call.argument("filePath")));
        } else if (call.method.equals("getVideoDuration")) {
            result.success(FileUtils.getVideoDuration(call.argument("filePath")));
        } else if (call.method.equals("getVideoResolution")) {
            result.success(FileUtils.getVideoResolution(call.argument("filePath")));
        } else if (call.method.equals("getVideoRatio")) {
            result.success(FileUtils.getVideoRatio(call.argument("filePath")));
        } else if (call.method.equals("getVideoSize")) {
            result.success(FileUtils.getVideoSize(call.argument("filePath")));
        } else if (call.method.equals("getVideoBitrate")) {
            result.success(FileUtils.getVideoBitrate(call.argument("filePath")));
        } else if (call.method.equals("saveCoverInLocal")) {
            result.success(FileUtils.saveCoverInLocal(call.argument("filePath")));
        } else if (call.method.equals("getChannel")) {
            // 获取android 渠道的东西
            result.success(DeviceUtils.getChannel(activity));
        } else if (call.method.equals("changIcon")) {
            // 获取android 渠道的东西
            DeviceUtils.changeIcon(activity, Objects.requireNonNull(call.argument("iconName")));
            result.success(true);
        } else if (call.method == "backDesktop") {
            result.success(true);
            activity.moveTaskToBack(false);
        }
    }
}
