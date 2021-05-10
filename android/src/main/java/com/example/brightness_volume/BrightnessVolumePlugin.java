package com.example.brightness_volume;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import android.app.Activity;
import android.provider.Settings;
import android.view.WindowManager;
import android.content.Context;
import android.media.AudioManager;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import android.os.Environment;
import android.os.StatFs;

/** BrightnessVolumePlugin */
public class BrightnessVolumePlugin implements FlutterPlugin, MethodCallHandler , ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private AudioManager  audioManager;
  private Activity      activity;
  private Context       ctx;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "brightness_volume");
    channel.setMethodCallHandler(this);
    this.ctx = flutterPluginBinding.getApplicationContext();
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch(call.method){
      case "brightness":
        result.success(getBrightness());
        break;
      case "setBrightness":
        double brightness = call.argument("brightness");
        WindowManager.LayoutParams layoutParams = this.activity.getWindow().getAttributes();
        layoutParams.screenBrightness = (float)brightness;
        this.activity.getWindow().setAttributes(layoutParams);
        result.success(null);
        break;
      case "resetCustomBrightness":
        WindowManager.LayoutParams layoutParamsReset = this.activity.getWindow().getAttributes();
        layoutParamsReset.screenBrightness = WindowManager.LayoutParams.BRIGHTNESS_OVERRIDE_NONE;
        this.activity.getWindow().setAttributes(layoutParamsReset);
        result.success(null);
        break;
      case "isKeptOn":
        int flags = this.activity.getWindow().getAttributes().flags;
        result.success((flags & WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON) != 0) ;
        break;
      case "keepOn":
        Boolean on = call.argument("on");
        if (on) {
          this.activity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        }
        else{
          this.activity.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        }
        result.success(null);
        break;
      case "volume":
        result.success(getVolume());
        break;
      case "setVolume":
        double volume = call.argument("volume");
        setVolume(volume);
        break;
      case "freeDiskSpace": {

        StatFs stat = new StatFs(Environment.getExternalStorageDirectory().getPath());
        Long bytesAvailable;
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.JELLY_BEAN_MR2)
          bytesAvailable = stat.getBlockSizeLong() * stat.getAvailableBlocksLong();
        else
          bytesAvailable = Long.valueOf(stat.getBlockSize()) * Long.valueOf(stat.getAvailableBlocks());
        result.success((bytesAvailable / (1024f * 1024f)));

        break;
      }
      case "totalDiskSpace":
        StatFs stat = new StatFs(Environment.getExternalStorageDirectory().getPath());
        Long bytesAvailable;

        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.JELLY_BEAN_MR2)
          bytesAvailable = stat.getBlockSizeLong() * stat.getBlockCountLong();
        else
          bytesAvailable = Long.valueOf(stat.getBlockSize()) * Long.valueOf(stat.getBlockCount());
        result.success((bytesAvailable / (1024f * 1024f)));

        break;
      default:
        result.notImplemented();
        break;
    }
  }


  private float getBrightness(){
    float result = this.activity.getWindow().getAttributes().screenBrightness;
    if (result < 0) { // the application is using the system brightness
      try {
        result = Settings.System.getInt(this.ctx.getContentResolver(), Settings.System.SCREEN_BRIGHTNESS) / (float)255;
      } catch (Settings.SettingNotFoundException e) {
        result = 1.0f;
        e.printStackTrace();
      }
    }
    return result;
  }



  private float getVolume() {
    if (audioManager == null) {
      audioManager = (AudioManager) this.activity.getSystemService(Context.AUDIO_SERVICE);
    }
    float max = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC);
    float current = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC);
    float target = current / max;

    return target;
  }

  private void setVolume(double volume) {
    if (audioManager == null) {
      audioManager = (AudioManager) this.activity.getSystemService(Context.AUDIO_SERVICE);
    }
    int max = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC);
    audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, (int) (max * volume), AudioManager.FLAG_PLAY_SOUND);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
     this.activity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {

  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
  }

  @Override
  public void onDetachedFromActivity() {

  }
}
