package com.daneed.background_timer;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import android.app.Application;
import android.app.Activity;
import android.os.PowerManager;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;

/** BackgroundTimerPlugin */
public class BackgroundTimerPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
  static MethodChannel channel;
  public PowerManager powerManager;
  public PowerManager.WakeLock wakeLock;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "background_timer");
    channel.setMethodCallHandler(new BackgroundTimerPlugin());

    channel.invokeMethod("onAttachedToEngine", null);
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  public static void registerWith(Registrar registrar) {
    channel = new MethodChannel(registrar.messenger(), "background_timer");

    final BackgroundTimerPlugin instance = new BackgroundTimerPlugin();
    if (registrar.activity() != null) {
      instance.powerManager = (PowerManager)registrar.activity().getSystemService(Application.POWER_SERVICE);
      instance.wakeLock = instance.powerManager.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "background_timer_wakelock_android");
    }

    channel.setMethodCallHandler(instance);

    channel.invokeMethod("registerWith", null);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("lowLevelHandlingEnabled")) {
      result.success(false);
    } else if (call.method.equals("backgroundTimerWillStart")) {
      if (wakeLock != null) {
        if (!wakeLock.isHeld()) {
          wakeLock.acquire();
        }
        result.success(true);
      } else {
        result.success(false);
      }
    } else if (call.method.equals("backgroundTimerWillEnd")) {
      if (wakeLock != null) {
        if (wakeLock.isHeld()) {
          wakeLock.release();
        }
        result.success(true);
      } else {
        result.success(false);
      }
      result.success(true);
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    /*if (wakeLock != null && wakeLock.isHeld()) {
      wakeLock.release();
    }
    wakeLock = null;
    powerManager = null;*/
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    /*if (wakeLock != null && wakeLock.isHeld()) {
      wakeLock.release();
    }
    wakeLock = null;
    powerManager = null;
    powerManager = (PowerManager)binding.getActivity().getSystemService(Application.POWER_SERVICE);
    wakeLock = powerManager.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "background_timer_wakelock_android");*/
  }

  @Override
  public void onDetachedFromActivity() {
    /*if (wakeLock != null && wakeLock.isHeld()) {
      wakeLock.release();
    }
    wakeLock = null;
    powerManager = null;*/
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
  }
}
