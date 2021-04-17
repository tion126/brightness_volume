#import "BrightnessVolumePlugin.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>

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
    else {
        result(FlutterMethodNotImplemented);
    }
    
}

@end
