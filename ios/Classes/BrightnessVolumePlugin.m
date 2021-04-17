#import "BrightnessVolumePlugin.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>
#include <sys/param.h>
#include <sys/mount.h>

@interface BrightnessVolumePlugin()

@property (strong, nonatomic) MPVolumeView *volumeView;
@property (strong, nonatomic) MPMusicPlayerController* musicController;
@end

@implementation BrightnessVolumePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"brightness_volume"
                                     binaryMessenger:[registrar messenger]];
    BrightnessVolumePlugin* instance = [[BrightnessVolumePlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"brightness" isEqualToString:call.method]) {
        result([NSNumber numberWithFloat:[UIScreen mainScreen].brightness]);
    }
    else if ([@"setBrightness" isEqualToString:call.method]) {
        NSNumber *brightness = call.arguments[@"brightness"];
        [[UIScreen mainScreen] setBrightness:brightness.floatValue];
        result(nil);
    }
    else if ([@"isKeptOn" isEqualToString:call.method]) {
        bool isIdleTimerDisabled =  [[UIApplication sharedApplication] isIdleTimerDisabled];
        result([NSNumber numberWithBool:isIdleTimerDisabled]);
    }
    else if ([@"keepOn" isEqualToString:call.method]) {
        NSNumber *b = call.arguments[@"on"];
        [[UIApplication sharedApplication] setIdleTimerDisabled:b.boolValue];
    }else if ([@"volume" isEqualToString:call.method]) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        CGFloat currentVol = audioSession.outputVolume;
        if (self.volumeView == nil) {
            self.volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-100, 0, 10, 10)];
            UIWindow *window = UIApplication.sharedApplication.keyWindow;
            [window addSubview:self.volumeView];
        }
        result(@(currentVol));
    }
    else if ([@"setVolume" isEqualToString:call.method]) {
        NSNumber *volume = call.arguments[@"volume"];
        if (self.musicController == nil) {
            self.musicController = [MPMusicPlayerController applicationMusicPlayer];
        }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        self.musicController.volume = volume.floatValue;
#pragma clang diagnostic pop
        result(nil);
    }
    else if ([@"freeDiskSpace" isEqualToString:call.method]){
        result(@(self.getAvailableDiskSize));
    }else if ([@"totalDiskSpace" isEqualToString:call.method]){
        result(@(self.getTotalDiskSize));
    }else {
        result(FlutterMethodNotImplemented);
    }
}

- (double)getTotalDiskSize {
    struct statfs buf;
    unsigned long long totalDiskSize = -1;
    if (statfs("/var", &buf) >= 0) {
        totalDiskSize = (unsigned long long)(buf.f_bsize * buf.f_blocks);
    }
    return totalDiskSize/1024/1024;
}

- (double)getAvailableDiskSize {
    struct statfs buf;
    unsigned long long availableDiskSize = -1;
    if (statfs("/var", &buf) >= 0) {
        availableDiskSize = (unsigned long long)(buf.f_bsize * buf.f_bavail);
    }
    return availableDiskSize/1024/1024;
}

- (NSString *)fileSizeToString:(unsigned long long)fileSize {
    NSInteger KB = 1024;
    NSInteger MB = KB*KB;
    NSInteger GB = MB*KB;

    if (fileSize < 10)  {
        return @"0 B";
    }else if (fileSize < KB) {
        return @"< 1 KB";
    }else if (fileSize < MB) {
        return [NSString stringWithFormat:@"%.2f KB",((CGFloat)fileSize)/KB];
    }else if (fileSize < GB) {
        return [NSString stringWithFormat:@"%.2f MB",((CGFloat)fileSize)/MB];
    }else {
         return [NSString stringWithFormat:@"%.2f GB",((CGFloat)fileSize)/GB];
    }
}


@end
