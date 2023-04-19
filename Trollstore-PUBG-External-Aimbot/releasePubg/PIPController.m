//
//  PiPAVPlayerViewController.m
//  PiPPlayerWithObjc
//
//  Created by 김혜리 on 2022/04/25.
//

//General code for this pulled from a project on github since it was easier, but its pretty basic. 

#import "PIPController.h"
#import <AVKit/AVKit.h>
#import "AVFoundation/AVFoundation.h"

@interface PIPController () <
AVPictureInPictureControllerDelegate
>

@property (nonatomic, retain) AVPictureInPictureController *pipController;

@end

@implementation PIPController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self settingUpPiPController];
}

- (void)settingUpPiPController {
    //Necessary for picture and picture
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];

    NSBundle* myBundle = [NSBundle mainBundle];
    NSString* mp4URL  = [myBundle pathForResource:@"video" ofType:@"mp4"];
    NSURL *url = [NSURL fileURLWithPath:mp4URL];
    AVPlayer *player = [[AVPlayer alloc] initWithURL: url];
    AVPlayerLayer *playerLayer = [[AVPlayerLayer alloc] init];
    [playerLayer setFrame: self.view.bounds];
    [playerLayer setPlayer: player];
    [self.view.layer addSublayer: playerLayer];
    [player play];

    if([AVPictureInPictureController isPictureInPictureSupported]){

        self.pipController = [[AVPictureInPictureController alloc] initWithPlayerLayer: playerLayer];
        self.pipController.delegate = self;
        [self.pipController startPictureInPicture];
        self.pipController.canStartPictureInPictureAutomaticallyFromInline = YES;

    } else {
        NSLog(@"not supported");
    }
}

- (void)pictureInPictureControllerWillStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"pictureInPictureControllerWillStartPictureInPicture");
}

- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"pictureInPictureControllerDidStartPictureInPicture");
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController failedToStartPictureInPictureWithError:(NSError *)error {
    NSLog(@"failedToStartPictureInPictureWithError");
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL))completionHandler {
    NSLog(@"restoreUserInterfaceForPictureInPictureStopWithCompletionHandler");
}

- (void)pictureInPictureControllerWillStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"pictureInPictureControllerWillStopPictureInPicture");
}

- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"pictureInPictureControllerDidStopPictureInPicture");
}

@end
